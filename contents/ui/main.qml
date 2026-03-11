/*
    SPDX-FileCopyrightText: 2013 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2014 Sebastian Kügler <sebas@kde.org>
    SPDX-FileCopyrightText: 2014 Kai Uwe Broulik <kde@privat.broulik.de>

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.wallpapers.image as Wallpaper
import org.kde.plasma.plasmoid
import QtQuick.Particles
import QtQuick3D
import QtQuick3D.Particles3D

WallpaperItem {
    id: root

    // used by WallpaperInterface for drag and drop
    onOpenUrlRequested: (url) => {
        if (root.pluginName === "org.kde.image") {
            const result = imageWallpaper.addUsersWallpaper(url);
            if (result.length > 0) {
                // Can be a file or a folder (KPackage)
                root.configuration.Image = result;
            }
        } else {
            imageWallpaper.addSlidePath(url);
            // Save drag and drop result
            root.configuration.SlidePaths = imageWallpaper.slidePaths;
        }
        root.configuration.writeConfig();
    }

    contextualActions: root.pluginName === "org.kde.rain" ? [openWallpaperAction, imageWallpaper.nextSlideAction] : []

    PlasmaCore.Action {
        id: openWallpaperAction
        text: i18nd("plasma_wallpaper_org.kde.image", "Open Wallpaper Image")
        icon.name: "document-open"
        onTriggered: imageView.mediaProxy.openModelImage();
    }

    Connections {
		enabled: root.pluginName === "org.kde.rain"
        target: Qt.application
        function onAboutToQuit() {
            root.configuration.writeConfig(); // Save the last position
        }
    }

    Component.onCompleted: {
        // In case plasmashell crashes when the config dialog is opened
        root.configuration.PreviewImage = "null";
        root.loading = true; // delays ksplash until the wallpaper has been loaded
    }

    ImageStackView {
        id: imageView
        anchors.fill: parent

        fillMode: root.configuration.FillMode
        configColor: root.configuration.Color
        blur: root.configuration.Blur
        source: {
            if (root.pluginName === "org.kde.rain") {
                return imageWallpaper.image;
            }
            if (root.configuration.PreviewImage !== "null") {
                return root.configuration.PreviewImage;
            }
            return root.configuration.Image;
        }
        sourceSize: Qt.size(root.width * Screen.devicePixelRatio, root.height * Screen.devicePixelRatio)
        wallpaperInterface: root

        Wallpaper.ImageBackend {
            id: imageWallpaper

            // Not using root.configuration.Image to avoid binding loop warnings
            configMap: root.configuration
            usedInConfig: false
            //the oneliner of difference between image and slideshow wallpapers
            renderingMode: (root.pluginName === "org.kde.image") ? Wallpaper.ImageBackend.SingleImage : Wallpaper.ImageBackend.SlideShow
            targetSize: imageView.sourceSize
            slidePaths: root.configuration.SlidePaths
            slideTimer: root.configuration.SlideInterval
            slideshowMode: root.configuration.SlideshowMode
            slideshowFoldersFirst: root.configuration.SlideshowFoldersFirst
            uncheckedSlides: root.configuration.UncheckedSlides

            // Invoked from C++
            function writeImageConfig(newImage: string) {
                configMap.Image = newImage;
            }
        }

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
                    emitRate: root.configuration.Particles
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
                            source: root.configuration.Rainflake
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

    Component.onDestruction: {
        if (root.pluginName === "org.kde.rain") {
            root.configuration.writeConfig(); // Save the last position
        }
    }
}
