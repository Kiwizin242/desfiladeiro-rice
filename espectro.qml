import QtQuick
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    preferredRepresentation: fullRepresentation
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    fullRepresentation: Item {
        Image {
            id: spectrum
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            cache: false
            asynchronous: false
        }

        Timer {
            interval: 50
            running: root.visible
            repeat: true
            triggeredOnStart: true
            onTriggered: spectrum.source = Qt.resolvedUrl("spectrum.svg")
                + "?" + Math.floor(Date.now() / interval)
        }
    }
}
