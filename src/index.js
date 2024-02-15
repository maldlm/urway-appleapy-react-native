import CryptoJS from 'crypto-js';
import { Alert, NativeModules, Platform } from 'react-native';
import { config } from '../../../src/utils/applepay';
const { Applepay } = NativeModules;

/**
 * Class representing URWAY payment
 */
export default class Urway {
  fe;
  /**
   *  initialize URWAY with the merchant identifier
   * @param {string} merchantIdentifier - name of your merchantIdentifier from your apple developer account
   */
  constructor(merchantIdentifier) {
    this.merchantIdentifier = merchantIdentifier;
  }

  /**
   *
   * @param {number} amount - amount to by paid by applepay
   * @param {string} trackId - order id
   * @param {string} label - name to be diplayed in applepay sheet
   * @param {string[]} allowedNetworks - name to be diplayed in applepay sheet
   *
   * @returns {Promise} - return an object of urway response please do check docs for more info
   */

  closeSheetApplePay(){
    Applepay.dismissApplePaySheet()
  }
  processPayment(amount, trackId, label, allowedNetworks) {
    return new Promise((res, rej) => {
      if (Platform.OS === 'android') {
        throw new Error('applepay is not supported in android devices');
      }
      if (!config) {
        rej('there is no config file in the root directory');
      }

      let valuesToBeHashed = `${trackId}|${config.terminalId}|${config.password}|${config.key}|${amount}|SAR`;
      let hash = CryptoJS.SHA256(valuesToBeHashed).toString();
      Applepay.createApplePayToken(
        this.merchantIdentifier,
        String(amount),
        label,
        allowedNetworks,
        async (err, token) => {
          if (err) {
            if (err === 'dismiss') {
              rej(err);
            } else {
            Alert.alert('Error', `${err}`, [
              {
                text: 'ok',
                style: 'default',
              },
            ]);
            rej(`error coming from ios ${err}`);
          }
          }
          let paymentRequest = this.generatePaymentRequest(
            token,
            hash,
            amount,
            String(trackId),
            rej
          );
          try {
            this.fe = await fetch(config.requestUrl, {
              method: 'POST',
              headers: {
                'Accept': 'application/json',
                'content-Type': 'application/json',
              },
              body: JSON.stringify(paymentRequest),
            });
            let result = await this.fe.json();
            res(result);
          } catch (e) {
            rej('something went wrong while sending the reqeust');
          }
        }
      );
    });
  }
  generatePaymentRequest(token, hash, amount, trackId, rej) {
    // if (token) {
    //   if (token.includes('Simulated', 100)) {
    //     Alert.alert('Error', `transaction was coming from a simulator`, [
    //       {
    //         text: 'ok',
    //         style: 'default',
    //       },
    //     ]);
    //     rej('transaction was coming from a simulator');
    //     return;
    //   }
    // }
    const paymentRequest = {
      trackid: trackId,
      terminalId: config.terminalId,
      action: '1',
      merchantIp: '10.10.10.10',
      password: config.password,
      amount: amount,
      requestHash: hash,
      country: 'SA',
      currency: 'SAR',
      customerIp: '46.153.46.140',
      applepayId: 'applepay',
      udf1: null,
      udf2: config.callbackUrl,
      udf3: null,
      udf4: 'ApplePay',
      udf5: token,
    };
    return paymentRequest;
  }
}
