/*
 * Copyright (C) 2021 Beijing Jingling Information System Technology Co., Ltd. All rights reserved.
 * 
 * Authors: 
 * Liu Bangguo <liubangguo@jingos.com>
 *
 */

import QtQuick 2.12
import QtQml 2.12
import QtGraphicalEffects 1.12
import QtQuick.Particles 2.12
import QtQuick.Window 2.12
import jingos.display 1.0

Rectangle {
    id: charged

    property url imageUrl
    property int circleDia
    property int arcWidth
    property color arcColor
    property color arcBackgroundColor
    property real  progress: 0
    width: circleDia
    height: circleDia
    radius: width / 2
    color: "transparent"

    Image {
        id: chargedImage

        smooth: true
        visible: true
        anchors.centerIn: parent
        source: imageUrl
        sourceSize: Qt.size(114 / appWidthRatio, 168 / appHeightRatio )
        antialiasing: true
        scale: 0.01
        opacity: 0
    }

    Canvas {
        id:canvasgrepcircle

        anchors.centerIn: chargedImage
        width: 2 * circleDia + arcWidth
        height: 2 * circleDia + arcWidth
        opacity: 0.01
        scale: 0

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0 , 0, canvas.width, canvas.height)
            ctx.beginPath()
            ctx.strokeStyle = arcBackgroundColor
            ctx.lineWidth = arcWidth
            ctx.arc(canvas.width / 2, canvas.height / 2, circleDia / 2, 0, Math.PI * 2, false)
            ctx.stroke()
        }
    }

    Rectangle {
        id: animation

        anchors.centerIn: chargedImage
        width: circleDia - arcWidth / 2
        height: circleDia - arcWidth / 2
        radius: circleDia / 2
        clip: true
        color: "transparent"

        ParticleSystem {
            anchors.fill: parent

            ImageParticle {
                groups: ["paopao"];
                source: "file:///usr/share/icons/jing/airBubbles.svg"

            }

            Emitter {
                id:leftEmitter

                anchors.bottom: parent.bottom
                anchors.bottomMargin: arcWidth
                anchors.horizontalCenter: parent.horizontalCenter

                group: "paopao"
                emitRate: 2
                lifeSpan: 1200
                size: 27;
                endSize: 4;
                sizeVariation: 15
                enabled: false

                acceleration: PointDirection {
                    y: -120
                }

                velocity: AngleDirection {
                    angle: 270
                    magnitude: 80 / appHeightRatio
                    angleVariation: 50
                    magnitudeVariation: 50 / appHeightRatio
                }
            }

            Emitter {
                id:middleEmitter

                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height / 8 + arcWidth
                anchors.left: parent.left
                anchors.leftMargin: parent.height / 8 + arcWidth

                enabled: false
                group: "paopao"
                emitRate: 2;
                lifeSpan: 1200
                size: 27;
                endSize: 4;
                sizeVariation: 15

                acceleration: PointDirection {
                    y: -120
                }

                velocity: AngleDirection {
                    angle: -45;
                    magnitude: 80 / appHeightRatio
                    angleVariation: 50;
                    magnitudeVariation: 50 / appHeightRatio
                }
            }

            Emitter {
                id: rightEmitter

                anchors.bottom: parent.bottom
                anchors.bottomMargin: parent.height / 8 + arcWidth
                anchors.right: parent.right
                anchors.rightMargin: parent.height / 8 + arcWidth

                group: "paopao"
                emitRate: 2;
                lifeSpan: 1200
                size: 27;
                endSize: 4;
                sizeVariation: 15
                enabled: false

                acceleration: PointDirection {
                    y: -120
                }

                velocity: AngleDirection {
                    angle: 225;
                    magnitude: 80 / appHeightRatio
                    angleVariation: 50;
                    magnitudeVariation: 50 / appHeightRatio
                }
            }
        }
    }

    Canvas {
        id: canvas

        anchors.centerIn: chargedImage
        width: 2 * circleDia + arcWidth
        height: 2 * circleDia + arcWidth

        scale: 1.2
        opacity: 0

        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, canvas.width, canvas.height)
            var r = progress * Math.PI / 180
            // var gradient = ctx.createConicalGradient(canvas.width / 2, canvas.height / 2, 2 * Math.PI)
            var gradient = ctx.createLinearGradient(0, canvas.height / 4, 0, canvas.height / 4 * 3 + arcWidth )
            gradient.addColorStop(0.0, "#00FF96")
            gradient.addColorStop(1.0, "#52FB6E")
            ctx.beginPath()
            ctx.lineCap = "round"
            ctx.strokeStyle = gradient
            // ctx.strokeStyle = arcColor
            ctx.lineWidth = arcWidth
            ctx.arc(canvas.width / 2, canvas.height / 2, circleDia / 2, 0  * Math.PI / 180 ,r , false)
            ctx.shadowColor = Qt.rgba(82 / 255, 251 / 255, 110 / 255, 1)
            ctx.shadowBlur = arcWidth * 1.5
            ctx.stroke()
        }
    }
    //if you ignore the glow effect, the performance is improve
//    FastBlur {
//         id: canvas
//         anchors.centerIn: chargedImage
//         width: 2 * circleDia + arcWidth
//         height: 2 * circleDia + arcWidth
//         scale: 1.2
//         opacity: 0
//         // anchors.fill: parent
//         source: canvas1
//         radius: 10
//         //  scale: 1.2
//         // opacity: 0
//     }

    RotationAnimation {
        id: canvasRotationAnimation

        target: canvas
        loops: Animation.Infinite
        running: false
        from: 0
        to: 360
        duration: 3000
    }

    PropertyAnimation {
        id: maskImageAnimationScale

        target: chargedImage
        properties: "opacity"
        to: 1.0
        duration: 150
    }

    PropertyAnimation {
        id: maskImageAnimationOpacity

        target: chargedImage
        properties: "scale"
        to: 1.2
        duration: 150

        onFinished: {
            maskImageAnimationScaleTo1.start()
        }
    }

    PropertyAnimation {
        id: maskImageAnimationScaleTo1

        target: chargedImage
        properties: "scale"
        to: 1.0
        duration: 50
    }

    PropertyAnimation {
        id: canvasgrepCircleAnimationOpacity

        target: canvasgrepcircle
        properties: "opacity"
        to: 1.0
        duration: 150
    }

    PropertyAnimation {
        id: canvasgrepCircleAnimationScale

        target: canvasgrepcircle
        properties: "scale"
        to: 1.2
        duration: 150

        onFinished: {
            canvasgrepCircleAnimationScaleTo1.running = true
        }
    }

    PropertyAnimation {
        id: canvasgrepCircleAnimationScaleTo1

        target: canvasgrepcircle
        properties: "scale"
        to: 1
        duration: 50

        onFinished: {
            canvasAnimationScaleTo1.running = true
            canvasAnimationOpacity.running = true
            chargedPercentOpacity.running = true
        }
    }

    Timer {
        id: canvasgrepCircleAnimationScaleTimer

        interval: 30
        repeat: false

        onTriggered: {
            canvasgrepCircleAnimationScale.running = true
            canvasgrepCircleAnimationOpacity.running = true
        }
    }

    PropertyAnimation {
        id: canvasAnimationScaleTo1

        target: canvas
        properties: "scale"
        to: 1
        duration: 50
    }

    PropertyAnimation {
        id: canvasAnimationOpacity

        target: canvas
        properties: "opacity"
        to: 1
        duration: 50

        onFinished: {
            canvasRotationAnimation.running = true
            leftEmitter.enabled = true
            middleEmitter.enabled = true
            rightEmitter.enabled = true
        }
    }

    PropertyAnimation {
        id: chargedPercentOpacity

        target: chargedPercent
        properties: "opacity"
        to: 1
        duration: 50

        onFinished: {
            chargedEndTimer.running = true
        }
    }

    Timer {
        id: chargedEndTimer

        interval: 1400
        repeat: false

        onTriggered: {
            chargedEndAnimationOpacity.running = true
        }
    }

    PropertyAnimation {
        id: chargedEndAnimationOpacity

        target: chargedroot
        properties: "opacity"
        to: 0
        duration: 100

        onFinished: {
            lockScreenChargedLoader.active = false
        }
    }

    Connections {
        target: maskAnimationOpacity

        onFinished: {
            chargedrootblur.opacity = 1
            canvasgrepCircleAnimationScaleTimer.start()
            maskImageAnimationOpacity.start()
            maskImageAnimationScale.start()
        }
    }
}



