
let planeHeight = 0.001
let rotationFactor = Float.pi * (35 / 180) // defined based on the euler angle from all models exported from 3DS Max
let scnExtension = "scn"
let daeNames: [String] = ["floor",
                          "actionIcons",
                          "arrow1",
                          "arrow2",
                          "arrowLong1",
                          "arrowLong2",
                          "arrowsChar1",
                          "arrowsChar2",
                          "arrowsCube",
                          "block",
                          "button",
                          "chat",
                          "curly1",
                          "curly2",
                          "curly3",
                          "cylinderSction",
                          "exea",
                          "geoSphere",
                          "grid1",
                          "grid2",
                          "higherButton",
                          "layers",
                          "leftCharArrow",
                          "loader1",
                          "loader2",
                          "pause",
                          "pill1",
                          "pill2",
                          "pill3",
                          "plate1",
                          "plate2",
                          "plate3",
                          "play",
                          "plusMinus",
                          "pointsArrow",
                          "slider",
                          "switch1",
                          "switch2",
                          "threeBalls",
                          "threeDots1",
                          "threeDots2",
                          "wave1",
                          "wave2",
                          "zoom",
                          "basePoles",
                          "pole1",
                          "pole2",
                          "pole3",
                          "flag"]

let projectTitle = "About this project"
let projectText = "This Swift playground was developed to take advantage of the advanced motion sensors and camera of this device, using ARKit. It has some elements inspired by the 2018’s edition of the WWDC page (they are all interactive). The frameworks used were ARKit, SceneKit, UIKit, and PlaygroundSupport. This Swift Playground will be best experienced when in fullscreen."

let meTitle = "About me"
let meText = "My name is Marcos, I'm a Brazilian student and iOS developer with a passion for coding, design and 3D modeling/animation. I'm looking forward to the opportunity to be part of the WWDC 2018 in San Jose."

let fromTitle = "Where I came from"
let fromText = "I'm currently living in southern Brazil, in a city called Canoas, from the Rio Grande do Sul region. It's a 78 years old city, with 350 thousand inhabitants."

let welcomeTitle = "WELCOME"
let welcomeText = "(1) Position your iPad's camera towards a plane surface (table, floor, etc) until you see green wireframe planes over it. Once you find a plane, touch it to project the AR content. (2) At this point, you'll be able to interact with all the 3D elements. Touch on the three orange buttons to see more info about this project."

let errorTitle = "ERROR"
let arErrorMessage = "Your device is not compatible with ARKit, please try another one."
let cameraErrorMessage = "Please authorize camera usage in system/settings to use this Playground."
let generalErrorMessage = "An error has occurred. Please try again later."
