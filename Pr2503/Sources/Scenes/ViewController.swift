import UIKit

class ViewController: UIViewController {

//    MARK: - Outlets

    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var passwordButton: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var stopButton: UIButton!

    var passwordToUnlock = "1!gr"
    var isRuningBruteForce = false

    var isBlack: Bool = false {
        didSet {
            if isBlack {
                self.view.backgroundColor = .black
            } else {
                self.view.backgroundColor = .white
            }
        }
    }

//    MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        addTapGestureToHideKeyboard()
        passwordTextField.isSecureTextEntry = true
    }

//    MARK: - Action

    @IBAction func generatePassword(_ sender: Any) {
        indicator.startAnimating()
        let text = passwordTextField.text
        DispatchQueue.global(qos: .userInteractive).async {
            if text != "" {
                self.bruteForce(passwordToUnlock: text ?? self.passwordToUnlock)
            } else {
                self.bruteForce(passwordToUnlock: self.passwordToUnlock)
            }

            DispatchQueue.main.async {
                self.indicator.stopAnimating()
                self.passwordTextField.isSecureTextEntry = false
            }
        }
    }

    @IBAction func onBut(_ sender: Any) {
        isBlack.toggle()
    }

    @IBAction func stopGeneratePassword(_ sender: Any) {
        DispatchQueue.main.async {
            self.passwordLabel.text = "Пароль не взломан"
        }
        isRuningBruteForce = false
    }

    func addTapGestureToHideKeyboard() {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapGesture))
            view.addGestureRecognizer(tapGesture)
        }

    @objc func tapGesture() {
        passwordTextField.isSecureTextEntry = true
        passwordTextField.resignFirstResponder()
        }

//    MARK: - Password selection func

    func bruteForce(passwordToUnlock: String) {
        let ALLOWED_CHARACTERS:   [String] = String().printable.map { String($0) }
        var password: String = ""
        isRuningBruteForce = true
        while password != passwordToUnlock {

            guard isRuningBruteForce else { break }

            password = generateBruteForce(password, fromArray: ALLOWED_CHARACTERS)

            DispatchQueue.main.async {
                self.passwordLabel.text = "Пароль: \(password)"
            }
            print(password)
        }
        print(password)
    }
}

extension String {
    var digits:      String { return "0123456789" }
    var lowercase:   String { return "abcdefghijklmnopqrstuvwxyz" }
    var uppercase:   String { return "ABCDEFGHIJKLMNOPQRSTUVWXYZ" }
    var punctuation: String { return "!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~" }
    var letters:     String { return lowercase + uppercase }
    var printable:   String { return digits + letters + punctuation }

    mutating func replace(at index: Int, with character: Character) {
        var stringArray = Array(self)
        stringArray[index] = character
        self = String(stringArray)
    }
}

func indexOf(character: Character, _ array: [String]) -> Int {
    return array.firstIndex(of: String(character))!
}

func characterAt(index: Int, _ array: [String]) -> Character {
    return index < array.count ? Character(array[index])
                               : Character("")
}

func generateBruteForce(_ string: String, fromArray array: [String]) -> String {
    var str: String = string

    if str.count <= 0 {
        str.append(characterAt(index: 0, array))
    }
    else {
        str.replace(at: str.count - 1,
                    with: characterAt(index: (indexOf(character: str.last!, array) + 1) % array.count, array))

        if indexOf(character: str.last!, array) == 0 {
            str = String(generateBruteForce(String(str.dropLast()), fromArray: array)) + String(str.last!)
        }
    }

    return str
}

