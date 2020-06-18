/** @jsx jsx */
import { css, jsx } from '@emotion/core'

export default function TargetGraph() {
  return <img src="/initialTarget.svg" alt={ALT_TEXT} css={rootStyle} />
}

const rootStyle = css({
  maxWidth: '100%',
  width: 670,
  height: 363,
  objectFit: 'contain',
  '@media (max-width: 420px)': {
    height: 280,
  },
})

const ALT_TEXT =
  'Initial Target: 50% CELO, 25% BTC,20% ETH 5% stable value portfolio (crypto assets with low volatility, candidates are decentralised stablecoins e.g. DAI)'
