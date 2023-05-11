//
//  ContentView.swift
//  PhotoRush
//
//  Created by Rexan Wong on 17/4/2023.
//

import SwiftUI
import PhotosUI
import CoreML

struct ContentView: View {
    @State var selectedImage: UIImage?
    @State var isShowingPhotoPicker = false
    @State var gameStarted = false
    @State var gameOver = false
    @State var randomWord = ""
    @State var predictionAndWordMatches = false
    @State var prediction: String = ""
    @State var totalPoints: Int = 0
    @State private var secondsRemaining = 300
    @State private var timer: Timer? = nil
    
    @State private var isShowingInstructions = false
    @State private var wwdcMode = false
    
    let model = MobileNetV2()
    
    func classifyImage() {
        guard let img = selectedImage,
            let resizedImage = img.resizeTo(size: CGSize(width: 224, height: 224)),
            let buffer = resizedImage.toBuffer() else {
            return
        }
        
        let output = try? model.prediction(image: buffer)
        
        if let output = output {
            prediction = output.classLabel
        }
    }
    
    var body: some View {
        ZStack {
            if gameOver {
                Color.cyan.ignoresSafeArea()
            } else if gameStarted == false {
                Color.white.ignoresSafeArea()
            } else {
                Color.white.ignoresSafeArea()
            }
            VStack {
                Text("PhotoRush")
                    .foregroundColor(Color.black)
                    .bold()
                    .font(.title)
                    .padding(.top)
                Text("The photo album game")
                    .foregroundColor(Color.black)
                    .font(.callout)
                
                if !gameStarted {
                    if isShowingInstructions {
                        ZStack {
                            Color.black.opacity(0.2).ignoresSafeArea()
                            ScrollView {
                                Text("Scroll down to see more")
                                    .font(.headline)
                                    .padding()
                                
                                Text("The aim of the game is simple : a random word will pop up, your task is to scroll through your photo album and try to find a picture that matches the random word! For example, if the random word is 'car', try to find a picture of a 🚗 in your photo album. If the CPU prediction model thinks that its prediction of your image is the same as the random word, you get 20 points! See how many points you can get in 5 mins!!!")
                                    .multilineTextAlignment(.center)
                                    .padding()

                                Text("If a certain picture is too difficult to find for a random word like 'croquet ball' (like why would u even have a pic of a croquet ball in ur photo album???), you can always click 'New word' to generate a new random word, and hopefully, an easier word like 'bicycle' to find!")
                                    .multilineTextAlignment(.center)
                                    .padding()

                                Text("Sometimes the prediction model may predict the object of your image wrongly. Please bear with that. It's a machine learning model after all :).")
                                    .multilineTextAlignment(.center)
                                    .padding()
                            }
                        }
                        .foregroundColor(Color.black)
                    }
                    
                    Button(action: {
                        isShowingInstructions.toggle()
                    }) {
                        Text(isShowingInstructions ? "Hide Instructions" : "Show Instructions")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color.blue)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    }
                    .padding()
                    
                    if !isShowingInstructions {
                        ScrollView {
                            Text("👋 Hey there, if you haven't played the game before, click 'Show Instructions' to learn how to play")
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Text("💻 Are you the WWDC judge?  If so, please click 'WWDC Mode'.  WWDC Mode is a mode specifically designed for testing at the WWDC Swift Student Challenge.  The pool of random words is more suited towards the photo album of the default ios simulator (if you're testing on the playground simulator).")
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Text("📱 However if you're testing the app on your personal device, even if you are the WWDC judge, feel free to use the default mode, with the random word being randomly chosen from a pool of 400+ words, making it a bit more fun!")
                                .multilineTextAlignment(.center)
                                .padding()
                            
                            Text("Therefore, I suggest testing this app on a personal device, as it will definitely have more photos on photo album compared to the 6 default photos on Apple's simulator")
                                .multilineTextAlignment(.center)
                                .padding()
                        }
                        .frame(height: 480)
                        
                        HStack {
                            Button(action: {
                                wwdcMode.toggle()
                            }) {
                                Image(systemName: wwdcMode ? "checkmark.square.fill" : "square")
                                    .foregroundColor(wwdcMode ? .green : .black)
                            }
                            
                            Text(wwdcMode ? "WWDC Mode : Activated" : "WWDC Mode : Deactivated")
                                .font(.title)
                            
                        }
                    }
                }
                
                    
                Spacer()
                
                
                
                
                if let image = selectedImage {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 250, height: 250)
                }
                
                if gameStarted {
                    if gameOver {
                        Text("GAME OVER")
                            .font(.largeTitle)
                        Text("\(totalPoints) PTS")
                            .font(.title)
                        
                        Button(action: {
                            selectedImage = nil
                            gameStarted = false
                            gameOver = false
                            randomWord = ""
                            predictionAndWordMatches = false
                            prediction = ""
                            totalPoints = 0
                            secondsRemaining = 300
                            timer?.invalidate()
                        }, label: {
                            Text("Play Again")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(minWidth: 0, maxWidth: .infinity)
                                .background(Color.black)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        })
                        .padding()
                    } else {
                        Button(action: {
                            self.isShowingPhotoPicker.toggle()
                        }) {
                            Text("Select Photo")
                                .font(.title3)
                                .foregroundColor(Color.blue)
                                
                        }
                        
                        if predictionAndWordMatches {
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.green, lineWidth: 2)
                                    .frame(width: 300, height: 300)
                                VStack {
                                    VStack {
                                        Text("YOUR WORD")
                                            .font(.callout)
                                        Text("\(randomWord)")
                                            .font(.largeTitle)
                                            .bold()
                                    }.padding()
                                    
                                    VStack {
                                        Text("CPU PREDICTION")
                                            .font(.callout)
                                        Text("\(prediction)")
                                            .font(.title)
                                            .bold()
                                    }.padding()
                                }
                            }
                        } else {
                            VStack {
                                Text("YOUR WORD")
                                    .font(.callout)
                                Text("\(randomWord)")
                                    .font(.largeTitle)
                                    .bold()
                            }.padding()
                            
                            VStack {
                                Text("CPU PREDICTION")
                                    .font(.callout)
                                Text("\(prediction)")
                                    .font(.title)
                                    .bold()
                            }.padding()
                        }
                        
                        
                        
                        Button(action: {
                            if wwdcMode {
                                self.selectWord(from: wwdcNouns)
                            } else {
                                self.selectWord(from: nouns)
                            }
                            
                        }, label: {
                            Text("New word!")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(minWidth: 0, maxWidth: 200)
                                .background(Color.blue)
                                .cornerRadius(10)
                                .padding(.horizontal)
                        })
                        .padding()
                        
                        HStack {
                            Text("\(totalPoints) PTS")
                                .font(.largeTitle)
                                .padding()
                            
                            Text(timeString(time: secondsRemaining))
                                .font(.largeTitle)
                                .padding()
                        }
                    }
                    
                
                } else {
                    Button(action: {
                        self.startGame()
                    }, label: {
                        Text("Start game")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(minWidth: 0, maxWidth: .infinity)
                            .background(Color.black)
                            .cornerRadius(10)
                            .padding(.horizontal)
                    })
                    .padding()
                }
                
                Spacer()
                
            }
            .foregroundColor(Color.black)
            
            .onChange(of: selectedImage) { _ in
                classifyImage()
            }
            .onChange(of: prediction) { newValue in
                predictionAndWordMatches = containsWord(sentence: newValue, word: randomWord)
                if predictionAndWordMatches {
                    totalPoints += 20
                }
            }
            .onChange(of: secondsRemaining) { newValue in
                gameOver = checkIfGameOver(secondsRemaining: newValue)
            }
            
            .onChange(of: randomWord) { newValue in
                predictionAndWordMatches = containsWord(sentence: prediction, word: newValue)
                if predictionAndWordMatches {
                    totalPoints += 20
                }
            }
            
            .sheet(isPresented: $isShowingPhotoPicker) {
                PhotoPicker(selectedImage: self.$selectedImage, prediction: self.$prediction)
            }
        }
    }
    
    func startGame() {
        gameStarted = true
        totalPoints = 0
        
        if wwdcMode {
            self.selectWord(from: wwdcNouns)
        } else {
            self.selectWord(from: nouns)
        }
        
        startTimer()
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if secondsRemaining > 0 {
                secondsRemaining -= 1
            } else {
                gameOver = true
            }
        }
    }
                      
    func checkIfGameOver(secondsRemaining : Int) -> Bool {
        if secondsRemaining == 0 {
            return true
        }
        return false
    }
    
    func timeString(time: Int) -> String {
            let minutes = time / 60
            let seconds = time % 60
            return String(format: "%02d:%02d", minutes, seconds)
    }
    
    func selectWord(from array: [String]) -> String? {
        guard !array.isEmpty else {
            return nil
        }
        let randomIndex = Int.random(in: 0..<array.count)
        
        randomWord = array[randomIndex]
        return array[randomIndex]
    }
    
    
    func containsWord(sentence: String, word: String) -> Bool {
        let wordsInSentence = sentence.lowercased().components(separatedBy: CharacterSet.whitespaces.union(CharacterSet.punctuationCharacters))
        return wordsInSentence.contains(word.lowercased())
    }

    @State var wwdcNouns = [
        "lemon",
        "apple",
        "fountain",
        "lakeside",
        "garden",
        "computer",
        "Tim Cook",
        "cliff"
    ]
    
    @State var nouns = [
        "aircraft",
        "alp",
        "ambulance",
        "analog clock",
        "ant",
        "apple",
        "armadillo",
        "artichoke",
        "ashcan",
        "backpack",
        "bagel",
        "bakery",
        "balloon",
        "banana",
        "bannister",
        "barbershop",
        "barn",
        "barrel",
        "basketball",
        "bassinet",
        "bathing cap",
        "beacon",
        "beaker",
        "bear",
        "bee",
        "bell pepper",
        "bench",
        "bicycle",
        "binoculars",
        "birdhouse",
        "black swan",
        "black widow",
        "blue jay",
        "bookshop",
        "bow",
        "bow tie",
        "boxing glove",
        "bracelet",
        "brain coral",
        "bread",
        "breakwater",
        "brick wall",
        "brown bear",
        "bubble",
        "buckeye",
        "buckle",
        "bullet train",
        "bustard",
        "butcher shop",
        "cab",
        "caldron",
        "candle",
        "cannon",
        "canoe",
        "capuchin",
        "car mirror",
        "car wheel",
        "carpenter's kit",
        "carton",
        "cash machine",
        "cassette",
        "castle",
        "catamaran",
        "cello",
        "chain",
        "chainlink fence",
        "chameleon",
        "cheetah",
        "chest",
        "chiffonier",
        "chime",
        "china cabinet",
        "Christmas stocking",
        "church",
        "cinema",
        "cliff",
        "cloak",
        "clog",
        "cocktail shaker",
        "coffee mug",
        "coil",
        "combination lock",
        "computer keyboard",
        "confectionery",
        "container ship",
        "convertible",
        "corkscrew",
        "corn",
        "cowboy boot",
        "crane",
        "crash helmet",
        "crate",
        "crib",
        "croquet ball",
        "crossword puzzle",
        "cucumber",
        "cup",
        "curtain",
        "daisy",
        "desk",
        "desktop computer",
        "diamond",
        "digital clock",
        "dining table",
        "dishwasher",
        "dock",
        "dogsled",
        "doll",
        "dolphin",
        "doormat",
        "drilling platform",
        "drum",
        "dumbbell",
        "Dutch oven",
        "electric fan",
        "electric guitar",
        "electric locomotive",
        "electric ray",
        "emerald",
        "entertainment center",
        "envelope",
        "espresso maker",
        "face powder",
        "feather boa",
        "file",
        "fireboat",
        "fire engine",
        "fire screen",
        "flagpole",
        "flamingo",
        "flat-coated retriever",
        "folding chair",
        "football helmet",
        "forklift",
        "fountain",
        "fountain pen",
        "four-poster",
        "freight car",
        "French horn",
        "French loaf",
        "frigate",
        "frog",
        "frying pan",
        "fur coat",
        "garbage truck",
        "garden hose",
        "garden spider",
        "gas pump",
        "gazelle",
        "giant panda",
        "goldfish",
        "golf ball",
        "gondola",
        "gong",
        "goose",
        "grand piano",
        "greenhouse",
        "grille",
        "grocery store",
        "guillotine",
        "guinea pig",
        "hair slide",
        "hair spray",
        "half track",
        "hammer",
        "hamper",
        "harmonica",
        "harp",
        "harvester",
        "hat",
        "head cabbage",
        "helicopter",
        "hen",
        "hermit crab",
        "hip",
        "hippopotamus",
        "horizontal bar",
        "horn",
        "hot air balloon",
        "hotdog",
        "hourglass",
        "house finch",
        "house fly",
        "hummingbird",
        "ice cream",
        "ice lolly",
        "impala",
        "indigo bunting",
        "instant pot",
        "iron",
        "jack-o'-lantern",
        "jeep",
        "jellyfish",
        "jersey",
        "jigsaw puzzle",
        "jinrikisha",
        "joystick",
        "junco",
        "kangaroo",
        "kayak",
        "keeshond",
        "kennel",
        "keyboard",
        "kite",
        "koala",
        "Komodo dragon",
        "ladle",
        "lampshade",
        "laptop",
        "lawn mower",
        "lemon",
        "lens cap",
        "leopard",
        "library",
        "lifeboat",
        "lighter",
        "limousine",
        "lion",
        "lipstick",
        "Loafer",
        "lollipop",
        "lynx",
        "mailbag",
        "mailbox",
        "maillot",
        "malinois",
        "manhole cover",
        "maraca",
        "marimba",
        "mask",
        "matchstick",
        "maypole",
        "maze",
        "measuring cup",
        "medicine chest",
        "megalith",
        "menu",
        "Mexican hairless",
        "microphone",
        "microwave",
        "military uniform",
        "milk can",
        "minibus",
        "minivan",
        "mitten",
        "mixing bowl",
        "mobile home",
        "Model T",
        "modem",
        "monarch butterfly",
        "monitor",
        "moped",
        "mosque",
        "mosquito net",
        "motor scooter",
        "mountain bike",
        "mountain tent",
        "mouse",
        "mousetrap",
        "moving van",
        "mushroom",
        "nail",
        "neck brace",
        "necklace",
        "nematode",
        "nipple",
        "notebook",
        "obelisk",
        "oboe",
        "ocarina",
        "odometer",
        "oil filter",
        "orange",
        "orangutan",
        "oscilloscope",
        "ostrich",
        "otter",
        "outdoor sign",
        "overskirt",
        "ox",
        "oxygen mask",
        "packet",
        "paddle",
        "paddlewheel",
        "padlock",
        "paintbrush",
        "paj",
        "pajama",
        "palace",
        "panpipe",
        "paper towel",
        "parachute",
        "parallel bars",
        "park bench",
        "parking meter",
        "passenger car",
        "patio",
        "pay-phone",
        "peacock",
        "pedestal",
        "pencil box",
        "pencil sharpener",
        "perfume",
        "Petri dish",
        "photocopier",
        "pick",
        "pickelhaube",
        "picket fence",
        "pickup",
        "pier",
        "piggy bank",
        "pill bottle",
        "pillow",
        "ping-pong ball",
        "pinwheel",
        "pirate",
        "pitcher",
        "plane",
        "planetarium",
        "plastic bag",
        "plate rack",
        "plow",
        "plunger",
        "pole",
        "police van",
        "poncho",
        "pool table",
        "pop bottle",
        "pot",
        "potpie",
        "prayer rug",
        "printer",
        "prison",
        "projectile",
        "projector",
        "puck",
        "pufferfish",
        "punching bag",
        "purse",
        "quill",
        "quilt",
        "racer",
        "racket",
        "radiator",
        "radio",
        "radio telescope",
        "rain barrel",
        "recreational vehicle",
        "reel",
        "reflex camera",
        "refrigerator",
        "remote control",
        "restaurant",
        "revolver",
        "rhinoceros",
        "ribbon",
        "rice cooker",
        "ring binder",
        "robin",
        "rocking chair",
        "rotary dial telephone",
        "rubber eraser",
        "rugby ball",
        "rule",
        "running shoe",
        "safe",
        "safety pin",
        "saltshaker",
        "sandal",
        "sarong",
        "saxophone",
        "scabbard",
        "scale",
        "school bus",
        "schooner",
        "scoreboard",
        "screen",
        "screw",
        "screwdriver",
        "sea anemone",
        "sea urchin",
        "seashore",
        "seat belt",
        "sewing machine",
        "shield",
        "shoe shop",
        "shopping basket",
        "shopping cart",
        "shovel",
        "shower cap",
        "shower curtain",
        "ski",
        "ski mask",
        "sleeping bag",
        "slide rule",
        "sliding door",
        "slot",
        "snail",
        "snake",
        "snorkel",
        "snowmobile",
        "snowplow",
        "soap dispenser",
        "soccer ball",
        "sock",
        "solar dish",
        "sombrero",
        "soup bowl",
        "space heater",
        "space shuttle",
        "spatula",
        "speedboat",
        "spider web",
        "spindle",
        "sports car",
        "spotlight",
        "stage",
        "steam locomotive",
        "steel arch bridge",
        "steel drum",
        "stethoscope",
        "stingray",
        "stone wall",
        "stopwatch",
        "stove",
        "strainer",
        "streetcar",
        "stretcher",
        "studio couch",
        "stupa",
        "submarine",
        "suit",
        "sundial",
        "sunglass",
        "sunglasses",
        "sunscreen",
        "suspension bridge",
        "swab",
        "sweatshirt",
        "swimming trunks",
        "swing",
        "switch",
        "syringe",
        "table lamp",
        "tank",
        "tape player",
        "teapot",
        "teddy bear",
        "television",
        "tennis ball",
        "thatch",
        "thimble",
        "thresher",
        "throne",
        "tile roof",
        "toaster",
        "tobacco shop",
        "toilet seat",
        "torch",
        "totem pole",
        "tow truck",
        "toyshop",
        "tractor",
        "traffic light",
        "trailer truck",
        "tray",
        "trench coat",
        "tricycle",
        "trimaran",
        "tripod",
        "triumphal arch",
        "trolleybus",
        "trombone",
        "tub",
        "turnstile",
        "typewriter keyboard",
        "umbrella",
        "unicycle",
        "upright",
        "vacuum",
        "vase",
        "vault",
        "velvet",
        "vending machine",
        "vestment",
        "viaduct",
        "violin",
        "volleyball",
        "waffle iron",
        "wall clock",
        "wallet",
        "wardrobe",
        "warplane",
        "washbasin",
        "washer",
        "water bottle",
        "water jug",
        "water tower",
        "whippet",
        "whistle",
        "wig",
        "window screen",
        "window shade",
        "Windsor tie",
        "wine bottle",
        "wing",
        "wok",
        "wolf",
        "wooden spoon",
        "wool",
        "worm fence",
        "wreck",
        "yawl",
        "yurt",
        "zebra"]
}

struct PhotoPicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    @Binding var prediction: String
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // Nothing to update
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(selectedImage: $selectedImage)
    }
    
    let model = MobileNetV2()
    
    class Coordinator: PHPickerViewControllerDelegate {
        @Binding var selectedImage: UIImage?
        
        init(selectedImage: Binding<UIImage?>) {
            _selectedImage = selectedImage
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            if let result = results.first {
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    if let image = image as? UIImage {
                        DispatchQueue.main.async {
                            self.selectedImage = image
                        }
                    }
                }
            } else {
                selectedImage = nil
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        
    }
    
    
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

