import withSession from '../../lib/session'
import marqetaClient from '../../lib/marqetaClient'


export default withSession(async (req, res) => {
  const { email, firstName, lastName } = await req.body

  console.log("failure point 1")
  try {
    const user = {
      isSignedIn: true,
      email: email,
      firstName: firstName,
      lastName: lastName
    }
    console.log("failure point 2")

    // --------------------------------------------------------------------------------

    // 1. Create the user on the Marqeta Platform.
    const mqUserResponse = await marqetaClient.post('/users', {
      "first_name": firstName,
      "last_name": lastName,
      email: email,
      "active": true
    })

    console.log("failure point 3")
    const mqUser = mqUserResponse.data
    console.log('Created user: ', mqUser)

    // 2. Create a card for the Marqeta user, linked to the pre-defined card product.
    // https://www.marqeta.com/docs/developer-guides/core-api-quick-start#_step_2_get_a_card_product_token
    console.log("failure point 4")
    const mqCardsResponse = await marqetaClient.post('/cards', {
      card_product_token: '7b18140e-f1ae-46ac-9909-2aeeed5e9a60',
      user_token: mqUser.token
    })

    console.log("failure point 5")
    const mqCard = mqCardsResponse.data
    console.log('Created card: ', mqCard)

    // 3. Fund the card
    // https://www.marqeta.com/docs/developer-guides/core-api-quick-start#_create_a_gpa_order_to_fund_a_user_account
    console.log("failure point 6")
    const mqGPAOrderResponse = await marqetaClient.post('/gpaorders', {
      "user_token": mqUser.token,
      "amount": "100.00",
      "currency_code": "USD",
      "funding_source_token": "sandbox_program_funding"
    })

    console.log("failure point 7")
    const mqGPAOrder = mqGPAOrderResponse.data
    console.log('GPA Order: ', mqGPAOrder)

    // 4. Store user and card on the session for the purposes of this sample app
    console.log("failure point 8")
    user.mqUser = mqUser
    user.mqCard = mqCard

    // --------------------------------------------------------------------------------


    
    req.session.set('user', user)
    await req.session.save()
    res.json(user)
  } catch (error) {
    console.error(error)
    const { response: fetchResponse } = error
    res.status(fetchResponse?.status || 500).json(error.data)
  }
})
