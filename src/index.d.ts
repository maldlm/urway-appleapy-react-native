declare module 'crypto-js' {
    const SHA256: {
      (data: string): { toString: () => string };
    };
  }

  declare module 'urway-appleapy-react-native' {
    interface UrwayConfig {
      terminalId: string;
      password: string;
      key: string;
      requestUrl: string;
      callbackUrl: string;
    }
  
    export const config: UrwayConfig;
  
    export default class Urway {
      fe: Response | undefined;
      merchantIdentifier: string;
  
      constructor(merchantIdentifier: string);

      closeSheetApplePay(): void;
  
      processPayment(
        amount: number,
        trackId: string,
        label: string,
        allowedNetworks: string[]
      ): Promise<any>;
  
      generatePaymentRequest(
        token: string,
        hash: string,
        amount: number,
        trackId: string,
        rej: (reason?: any) => void
      ): any;
    }
  }

