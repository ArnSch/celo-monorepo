import Button, { BtnSizes } from '@celo/react-components/components/Button.v2'
import Touchable from '@celo/react-components/components/Touchable'
import QRCodeBorderlessIcon from '@celo/react-components/icons/QRCodeBorderless'
import colors from '@celo/react-components/styles/colors.v2'
import variables from '@celo/react-components/styles/variables'
import React from 'react'
import { useTranslation } from 'react-i18next'
import { StyleSheet, View } from 'react-native'
import { Namespaces } from 'src/i18n'
import { navigate } from 'src/navigator/NavigationService'
import { Screens } from 'src/navigator/Screens'

export default function SendOrRequestBar() {
  const onPressSend = () => {
    navigate(Screens.Send, { isRequest: false })
  }

  const onPressRequest = () => {
    navigate(Screens.Send, { isRequest: true })
  }

  const onPressQrCode = () => {
    navigate(Screens.QRNavigator)
  }

  const { t } = useTranslation(Namespaces.sendFlow7)

  return (
    <View style={styles.container} testID="SendOrRequestBar">
      <Button
        style={styles.button}
        size={BtnSizes.SMALL}
        text={t('send')}
        onPress={onPressSend}
        testID="SendOrRequestBar/SendButton"
      />
      <Button
        style={[styles.button, styles.requestButton]}
        size={BtnSizes.SMALL}
        text={t('paymentRequestFlow:request')}
        onPress={onPressRequest}
        testID="SendOrRequestBar/RequestButton"
      />
      <Touchable borderless={true} onPress={onPressQrCode}>
        <QRCodeBorderlessIcon height={32} color={colors.greenUI} />
      </Touchable>
    </View>
  )
}

const styles = StyleSheet.create({
  container: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: variables.contentPadding,
    paddingVertical: 12,
    borderTopColor: colors.gray2,
    borderTopWidth: 1,
  },
  button: {
    flex: 1,
    flexDirection: 'column',
  },
  requestButton: {
    marginHorizontal: 12,
  },
})
