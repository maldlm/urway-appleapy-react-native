# urway-appleapy-react-native

adding applepay in react-native

## Installation

```sh
npm install urway-appleapy-react-native
```

## guides

1. First make sure to follow the guide on [Setting Up Apple Pay](https://developer.apple.com/documentation/passkit/apple_pay/setting_up_apple_pay).
2. Make sure to create an pk8 certificate in order for urway to decrypt the payment you can refer to the urway document on how to create it refer to section E [create a pk8](https://www.dropbox.com/sh/g2z65cfd6ioj5co/AAD8tMtuswPZ-fb5-VUKQCmga/DirectApplePay?dl=0&preview=certificate_creation_for_applepay.pdf&subfolder_nav_tracking=1).
3. Add a config file in your root directory and export your credentials key form

```js
export const config = {
  currency: 'SAR',
  terminalId: '******',
  password: '*****',
  key: '********',
  requestUrl: '********',
};
```

4. After installing the package make sure to link it to xcode by cleaning the build and the pod file

```sh
cd ios
rm -rf ios/build
rm -rf ios/Pods
pod install
```

## Usage

- you will import Urway as shown below and initlalize it by creating instance of the class urway
- when ever you went make a payment call **processPayment** this funciton will accept three parameter
  - amount : amount to be paid
  - order id : order number from your side
  - label : this name will be shown in the payment sheet

```js
import Urway from 'urway-appleapy-react-native';
// ...
//initialize  urway applepay
const pay = new Urway('merchant.example.com');
//....

try {
  let result = await pay.processPayment(20, '22', 'urway');
  console.log(res);
} catch (e) {
  console.log(e);
}
```

## License

MIT

---

Made with [create-react-native-library](https://github.com/callstack/react-native-builder-bob)
