import QtQuick
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.plasma.components as PlasmaComponents
import org.kde.plasma.plasmoid
import org.kde.plasma.private.mpris as Mpris
import org.kde.plasma.plasma5support as PlasmaSupport

PlasmoidItem {
    id: root

    readonly property var player: playerModel.currentPlayer
    readonly property string artworkUrl: player ? player.artUrl : ""
    readonly property bool remoteArtwork: /^https?:\/\//i.test(artworkUrl)
    readonly property string coverCommand: remoteArtwork
        ? "/usr/bin/python3 " + shellArgument(decodeURIComponent(String(Qt.resolvedUrl("fetch-cover.py")).slice(7)))
            + " " + shellArgument(artworkUrl)
        : ""
    property url downloadedArtwork: ""

    onArtworkUrlChanged: downloadedArtwork = ""

    function shellArgument(value) {
        return "'" + value.replace(/'/g, "'\\''") + "'"
    }

    component MediaButton: PlasmaComponents.ToolButton {
        Layout.minimumWidth: 24
        Layout.preferredWidth: 24
        Layout.minimumHeight: 0
        Layout.preferredHeight: 22
        Layout.maximumHeight: 22
        Layout.alignment: Qt.AlignVCenter
        padding: 2
        icon.width: 16
        icon.height: 16
    }

    preferredRepresentation: fullRepresentation
    fullRepresentation: Item {
        Layout.minimumWidth: controls.implicitWidth + 8
        Layout.preferredWidth: Layout.minimumWidth
        Layout.fillHeight: true
        clip: true

        RowLayout {
            id: controls
            anchors.centerIn: parent
            width: implicitWidth
            height: implicitHeight
            spacing: 4

            Item {
                Layout.preferredHeight: 22
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 22
                clip: true

                Kirigami.Icon {
                    anchors.fill: parent
                    source: "audio-x-generic"
                    visible: cover.status !== Image.Ready
                }
                Image {
                    id: cover
                    anchors.fill: parent
                    source: root.remoteArtwork ? root.downloadedArtwork : root.artworkUrl
                    sourceSize.width: 96
                    sourceSize.height: 96
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }

            PlasmaComponents.Label {
                Layout.preferredWidth: 140
                Layout.alignment: Qt.AlignVCenter
                text: root.player?.track
                    ? [root.player.track, root.player.artist].filter(Boolean).join("  ·  ")
                    : "Sem reprodução"
                elide: Text.ElideRight
                font.bold: true
            }

            MediaButton {
                icon.name: "media-skip-backward"
                Accessible.name: "Faixa anterior"
                enabled: root.player?.canGoPrevious ?? false
                onClicked: root.player.Previous()
            }

            MediaButton {
                icon.name: root.player?.playbackStatus === Mpris.PlaybackStatus.Playing
                    ? "media-playback-pause" : "media-playback-start"
                Accessible.name: "Reproduzir ou pausar"
                enabled: (root.player?.canPlay ?? false) || (root.player?.canPause ?? false)
                onClicked: root.player.PlayPause()
            }

            MediaButton {
                icon.name: "media-skip-forward"
                Accessible.name: "Próxima faixa"
                enabled: root.player?.canGoNext ?? false
                onClicked: root.player.Next()
            }

            AnimatedImage {
                Layout.preferredWidth: 22
                Layout.preferredHeight: 22
                Layout.alignment: Qt.AlignVCenter
                source: ""
                visible: status === Image.Ready
                fillMode: Image.PreserveAspectFit
                smooth: false
                playing: visible
                Accessible.name: "Ralsei, de Deltarune"
            }
        }
    }

    Mpris.Mpris2Model {
        id: playerModel
    }

    PlasmaSupport.DataSource {
        engine: "executable"
        connectedSources: root.coverCommand ? [root.coverCommand] : []
        onNewData: (command, result) => {
            if (command === root.coverCommand && result["exit code"] === 0) {
                root.downloadedArtwork = result.stdout.trim()
            }
        }
    }
}
