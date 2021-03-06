/*
Copyright (C) 2015 Olavi Haapala.
<harbourwht@gmail.com>
Twitter: @0lpeh
IRC: olpe
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are met:

* Redistributions of source code must retain the above copyright notice, this
  list of conditions and the following disclaimer.

* Redistributions in binary form must reproduce the above copyright notice,
  this list of conditions and the following disclaimer in the documentation
  and/or other materials provided with the distribution.

* Neither the name of wht nor the names of its
  contributors may be used to endorse or promote products derived from
  this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

import QtQuick 2.0
import Sailfish.Silica 1.0
import "../config.js" as DB

Page {
    id: projectss
    allowedOrientations: Orientation.Portrait | Orientation.Landscape | Orientation.LandscapeInverted

    function getProjects() {
        projects = db.getProjects()
        for (var i = 0; i < projects.length; i++) {
            projectsModel.set(i, {
                'id': projects[i].id,
                'name': projects[i].name,
                'hourlyRate': projects[i].hourlyRate,
                'contractRate':projects[i].contractRate,
                'budget': projects[i].budget,
                'hourBudget': projects[i].hourBudget,
                'labelColor': projects[i].labelColor
            })
        }
    }

    SilicaFlickable{
        anchors.fill: parent

        ListModel {
            id: projectsModel
        }

        SilicaListView {
            id: listView
            spacing: Theme.paddingLarge
            anchors.fill: parent
            quickScroll: true
            model: projectsModel
            header: PageHeader {
                title: qsTr("All projects")
            }

            PullDownMenu {
                MenuItem {
                    text: qsTr("Add project")
                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("AddProject.qml"),{prev: projectss})
                    }
                }
            }

            VerticalScrollDecorator {}

            ViewPlaceholder {
                        enabled: listView.count == 0
                        text: qsTr("No projects found")
            }

            delegate: Item {
                id: myListItem
                property Item contextMenu
                property bool menuOpen: contextMenu != null && contextMenu.parent === myListItem
                width: ListView.view.width
                height: menuOpen ? contextMenu.height + contentItem.childrenRect.height: contentItem.childrenRect.height

                BackgroundItem {
                    id: contentItem
                    width: parent.width

                    Rectangle{
                        height: 15
                        color: Theme.rgba(model.labelColor, Theme.highlightBackgroundOpacity)
                        anchors.fill: parent

                        Item {
                            width: childrenRect.width
                            y: Theme.paddingLarge
                            x: Theme.paddingLarge

                            Label {
                                id: projectName
                                text: model.name
                                font{
                                    bold: true
                                    pixelSize: Theme.fontSizeMedium
                                }
                            }

                            Label {
                                visible: model.id === defaultProjectId
                                id: defaultProjectLabel
                                text: "  (" + qsTr("Default project") + ")"
                                anchors.left: projectName.right
                                font{
                                    bold: true
                                    pixelSize: Theme.fontSizeMedium
                                }
                            }
                        }
                    }

                    onClicked: {
                        pageStack.push(Qt.resolvedUrl("AddProject.qml"),{
                                           prev: projectss,
                                           editMode: true,
                                           projectId: model.id,
                                           name: model.name,
                                           hourlyRate: model.hourlyRate,
                                           contractRate: model.contractRate,
                                           budget: model.budget,
                                           hourBudget: model.hourBudget,
                                           labelColor: model.labelColor
                                       })
                    }

                    onPressAndHold: {
                        if (!contextMenu) {
                            contextMenu = contextMenuComponent.createObject(listView)
                        }

                        contextMenu.show(myListItem)
                    }
                }

                RemorsePopup { id: remorse }

                function remove() {
                    remorse.execute(qsTr("Removing"), function() {
                        if(db.remove("project", model.id)) {
                            projectsModel.remove(index)
                            getProjects()
                        }
                        else {
                            banner.notify("Removing failed!")
                        }
                    })
                }
            }

            Component {
               id: contextMenuComponent

               ContextMenu {
                   id: menu

                   MenuItem {
                       text: qsTr("Remove")
                       onClicked: {
                           menu.parent.remove()
                       }
                   }
               }
            }
        }
    }

    Banner {
        id: banner
    }

    Component.onCompleted: {
        defaultProjectId = settings.getDefaultProjectId()
        getProjects()
    }
}


