/*
    SPDX-FileCopyrightText: 2015 Ivan Safonov <safonov.ivan.s@gmail.com>
    SPDX-FileCopyrightText: 2024 Steve Storey <sstorey@gmail.com>
    SPDX-FileCopyrightText: 2024 Victor Calles <vcalles@gmail.com>

    SPDX-License-Identifier: GPL-3.0-only
*/
import QtQuick
import QtQuick.Particles
import QtQuick3D
import QtQuick3D.Particles3D

import org.kde.plasma.plasmoid

WallpaperItem {
    id: wallpaper
    Image {
        id: root
        anchors.fill: parent

        fillMode: wallpaper.configuration.FillMode
        source: wallpaper.configuration.Image

        readonly property int velocity: wallpaper.configuration.Velocity
        readonly property int numParticles: wallpaper.configuration.Particles
        readonly property int particleSize: wallpaper.configuration.Size
        readonly property int particleLifeSpan: 1.5 * height / velocity

    View3D {
        anchors.fill: parent

        environment: SceneEnvironment {
            clearColor: "#202020"
            backgroundMode: SceneEnvironment.Transparent
            antialiasingMode: SceneEnvironment.MSAA
        }

        PerspectiveCamera {
            id: camera
            position: Qt.vector3d(0, 100, 600)
            clipFar: 2000
        }

        PointLight {
            position: Qt.vector3d(200, 600, 400)
            brightness: 40
            ambientColor: Qt.rgba(0.2, 0.2, 0.2, 1.0)
        }


ParticleSystem3D {
    id: lightRain
    y: 2000
    ParticleEmitter3D {
        id: lightRainEmitter
        emitRate: root.numParticles
        lifeSpan: 500
        particle: lightRainParticle
        particleScale: 0.75
        particleScaleVariation: 0.25
        velocity: lightRainDirection
        shape: lightRainShape
        depthBias: -200

        VectorDirection3D {
            id: lightRainDirection
            direction.y: -(lightRain.y * 2)
        }

        SpriteParticle3D {
            id: lightRainParticle
            color: "#90e6f4ff"
            maxAmount: 300
            particleScale: 200
            fadeInDuration: 0
            fadeOutDuration: 20
            fadeOutEffect: Particle3D.FadeOpacity
            sortMode: Particle3D.SortDistance
            sprite: lightRainTexture
            offsetY: 1
            billboard: true

            Texture {
                id: lightRainTexture
                source: wallpaper.configuration.Rainflake
            }

            SpriteSequence3D {
                id: lightRainSequence
                duration: 15
                randomStart: true
                animationDirection: SpriteSequence3D.Normal
                frameCount: 3
                interpolate: true
            }
        }
    }

    ParticleShape3D {
        id: lightRainShape
        extents.x: 500
        extents.y: 0.5
        extents.z: 500
        type: ParticleShape3D.Cube
        fill: true
    }

    TrailEmitter3D {
        id: lightRainSplashEmitter
        emitRate: 0
        lifeSpan: 800
        particle: lightRainSplashParticle
        particleScale: 15
        particleScaleVariation: 15
        follow: lightRainParticle
        emitBursts: lightRainSplashBurst
        depthBias: -10

        SpriteParticle3D {
            id: lightRainSplashParticle
            color: "#8bc0e7fb"
            maxAmount: 250
            sprite: lightRainSplashTexture
            spriteSequence: lightRainSplashSequence
            fadeInDuration: 450
            fadeOutDuration: 800
            fadeInEffect: Particle3D.FadeScale
            fadeOutEffect: Particle3D.FadeOpacity
            sortMode: Particle3D.SortDistance
            billboard: true
            offsetY: 1

            Texture {
                id: lightRainSplashTexture
                source: "data/splash7.png"
            }

            SpriteSequence3D {
                id: lightRainSplashSequence
                duration: 800
                frameCount: 6
            }
        }

        DynamicBurst3D {
            id: lightRainSplashBurst
            amount: 1
            triggerMode: DynamicBurst3D.TriggerEnd
        }
    }
}


}
}
}

