// import Urway from 'urway-appleapy-react-native';
import {
  Text,
  View,
  StyleSheet,
  Button,
  Linking,
  NativeModules,
  Touchable,
} from 'react-native';
const main = () => {
  // const pay = new Urway('merchant.urwach.applepay');

  const callPayment = async () => {
    try {
      // let res = await pay.processPayment(1000, '22', 'urway');
      // console.log(res);
    } catch (e) {
      console.log('from payment ' + e);
    }
  };

  let style = StyleSheet.create({
    main: {
      marginVertical: '10%',
      flex: 1,
      alignItems: 'center',
      justifyContent: 'center',
    },
    firstView: {
      justifyContent: 'center',
      alignItems: 'center',
      flexDirection: 'row',
    },
    secondView: {
      width: '100%',
      alignItems: 'stretch',
      // justifyContent: 'flex-end',
      flex: 1,
    },
    thirdView: {
      justifyContent: 'center',
      width: '100%',
      flex: 1,
      flexDirection: 'row',
    },
    text: {
      color: 'magenta',
      fontSize: 50,
      fontWeight: 'bold',
    },
  });
  return (
    <View style={style.main}>
      <Button title="make payment" onPress={callPayment}></Button>
    </View>
  );
};

export default main;
