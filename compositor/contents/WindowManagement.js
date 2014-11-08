/*
 *   Copyright 2014 Pier Luigi Fiorini <pierluigi.fiorini@gmail.com>
 *
 *   This program is free software; you can redistribute it and/or modify
 *   it under the terms of the GNU Library General Public License as
 *   published by the Free Software Foundation; either version 2, or
 *   (at your option) any later version.
 *
 *   This program is distributed in the hope that it will be useful,
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *   GNU Library General Public License for more details
 *
 *   You should have received a copy of the GNU Library General Public
 *   License along with this program; if not, write to the
 *   Free Software Foundation, Inc.,
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
 */

/*
 * Main procedures
 */

function surfaceMapped(surface) {
    // Determine if it's a shell window
    var firstView = compositor.firstViewOf(surface);
    var isShellWindow =
        (typeof(firstView.role) != "undefined") ||
        (surface.className == "plasmashell.desktop");

    // Print some information
    if (isShellWindow) {
        console.debug("Shell surface", surface, "mapped");
        console.debug("\trole:", firstView.role);
        console.debug("\tsize:", surface.size.width + "x" + surface.size.height);
    } else {
        console.debug("Application surface", surface, "mapped");
        console.debug("\tappId:", surface.className);
        console.debug("\ttitle:", surface.title);
        console.debug("\tsize:", surface.size.width + "x" + surface.size.height);
    }

    // Call a specialized method to deal with application or
    // shell windows
    if (isShellWindow)
        mapShellSurface(surface, firstView);
    else
        mapApplicationSurface(surface);
}

function surfaceUnmapped(surface) {
    // Determine if it's a shell window
    var firstView = compositor.firstViewOf(surface);
    var isShellWindow =
        (typeof(firstView.role) != "undefined") ||
        (surface.className == "plasmashell.desktop");

    // Print some information
    if (typeof(firstView.role) == "undefined") {
        console.debug("Shell surface", surface, "unmapped");
        console.debug("\trole:", firstView.role);
        console.debug("\tsize:", surface.size.width + "x" + surface.size.height);
    } else {
        console.debug("Application surface", surface, "unmapped");
        console.debug("\tappId:", surface.className);
        console.debug("\ttitle:", surface.title);
    }

    // Call a specialized method to deal with application or
    // shell windows
    if (isShellWindow)
        unmapShellSurface(surface);
    else
        unmapApplicationSurface(surface);
}

function surfaceDestroyed(surface) {
    console.debug("Surface", surface, "destroyed");

    // Remove surface from model
    var i;
    for (i = 0; i < surfaceModel.count; i++) {
        var entry = surfaceModel.get(i);

        if (entry.surface === surface) {
            // Destroy window representation and
            // remove the surface from the model
            if (entry.window.chrome)
                entry.window.chrome.destroy();
            entry.window.destroy();
            surfaceModel.remove(i, 1);
            break;
        }
    }
}

/*
 * Map surfaces
 */

function mapApplicationSurface(surface) {
    // Just exit if we already created a window representation
    var i;
    for (i = 0; i < surfaceModel.count; i++) {
        var entry = surfaceModel.get(i);

        if (entry.surface === surface)
            return;
    }

    // Create surface item
    var component = Qt.createComponent("ClientWindowWrapper.qml");
    if (component.status !== Component.Ready) {
        console.error(component.errorString());
        return;
    }

    // Request a view for this output although with phones will
    // likely have just one output
    var child = compositor.viewForOutput(surface, _greenisland_output);

    // Create and setup window container
    var window = component.createObject(compositorRoot.layers.windows, {"child": child});
    window.child.parent = window;
    window.child.touchEventsEnabled = true;
    //surface.requestSize(window.parent.width, window.parent.height);
    window.anchors.top = window.parent.top;
    window.anchors.left = window.parent.left;
    window.width = surface.size.width;
    window.height = surface.size.height;

    // Switch to the applications layer and take focus
    compositorRoot.showHome = false;
    compositorRoot.currentWindow = window;
    window.child.takeFocus();

    // Run map animation
    if (typeof(window.runMapAnimation) != "undefined")
        window.runMapAnimation();

    // Add surface to the model
    surfaceModel.append({"surface": surface, "window": window});
}

function mapShellSurface(surface, child) {
    // Shell surfaces have only one view which is passed to us
    // as an argument, check whether it's a view for this output
    // or not
    if (child.output !== _greenisland_output)
        return;

    // Just set z-index and exit if we already created a
    // window representation
    var i;
    for (i = 0; i < surfaceModel.count; i++) {
        var entry = surfaceModel.get(i);

        if (entry.surface === surface) {
            // Set the appropriate z-index
            entry.window.z = (surface.className == "plasmashell.desktop") ? 1 : 0;

            // Switch to the desktop layer and take focus
            compositorRoot.showHome = true;
            compositorRoot.currentWindow = null;
            entry.window.child.takeFocus();

            return;
        }
    }

    // Create surface item
    var component = Qt.createComponent("ShellWindowWrapper.qml");
    if (component.status !== Component.Ready) {
        console.error(component.errorString());
        return;
    }

    // Create and setup window container
    // XXX: We only support desktop roles for now
    var window = component.createObject(compositorRoot.layers.desktop, {"child": child});
    window.child.parent = window;
    window.child.touchEventsEnabled = true;
    window.x = window.y = 0;
    window.width = surface.size.width;
    window.height = surface.size.height;

    // Set a higher z-index to windows created by the shell but
    // not handled by the protocol (i.e. not home screen)
    window.z = (surface.className == "plasmashell.desktop") ? 1 : 0;

    // Switch to the desktop layer and take focus
    compositorRoot.showSplash = false;
    compositorRoot.showHome = true;
    window.child.takeFocus();

    // Add surface to the model
    surfaceModel.append({"surface": surface, "window": window});
}

/*
 * Unmap surfaces
 */

function unmapApplicationSurface(surface) {
    // Reactivate home layer as soon as an application window is unmapped
    compositorRoot.showHome = true;
    compositorRoot.currentWindow = null;
}

function unmapShellSurface(surface) {
    // Lower unmapped shell surfaces not handled by the protocol
    // (i.e. not home screen like sliding window)
    if (surface.className == "plasmashell.desktop") {
        var i;
        for (i = 0; i < surfaceModel.count; i++) {
            var entry = surfaceModel.get(i);

            if (entry.surface === surface) {
                entry.window.z = -1;
                return;
            }
        }
    }
}
