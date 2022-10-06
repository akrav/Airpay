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

    // const mqJitGatewayResponse = await marqetaClient.post('/fundingsources/programgateway', 
    // {
    //   "token": "8d19434e-645e-4606-9d7b-6fa5925da110",
    //   "basic_auth_username": "my_username",
    //   "basic_auth_password": "My_20-to-50-character_password",
    //   "url": "https://hyperm.free.beeceptor.com/",
    //   "name": "hypermatter_bank"
    // })

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
      card_product_token: '5863443b-5524-495d-b3ad-74067648f64a',
      user_token: mqUser.token
    })

    console.log("failure point 5")
    const mqCard = mqCardsResponse.data
    console.log('Created card: ', mqCard)


    // 4. Store user and card on the session for the purposes of this sample app
    console.log("failure point 8")
    user.mqUser = mqUser
    user.mqCard = mqCard

    // --------------------------------------------------------------------------------

    //Possible Move response
    const [isApproved, setIsApproved] = React.useState("DECLINED");

    const mqSpendApprovalRequest = await marqetaClient.get('/user/12345')
    .then( async (response) => {
        
            // Which amount to use?
            // response.data.amount;
            // response.data.gpa_order.amount;
            // response.data.jit_funding.amount;
            const transaction_amount = response.data.gpa_order.amount;
            const transaction = {
            type: "entry_function_payload",
            function: `${address}::module_or_script_name::module_or_script_function`,
            arguments: [transaction_amount],//[stringToHex(message)],
            type_arguments: [],
            };

            try {
                setIsApproved(await window.aptos.signAndSubmitTransaction(transaction));
            } 
            catch {
                setIsApproved("DECLINED");
            }
        
    });
    

    const mqSpendApprovalResponse = await marqetaClient.post('/user/12345',
    {
        "transaction": {
          "type": "authorization",
          "state": isApproved,
          "identifier": "16",
          "token": "e7e77df5-deb2-4433-b397-40a34a70fd1b",
          "user_token": "eb7b0af2-3f00-474d-9a05-611adc8af57d",
          "acting_user_token": "eb7b0af2-3f00-474d-9a05-611adc8af57d",
          "card_token": "07e8882d-fa81-4689-bca8-6f24852a6c08",
          "card_product_token": "5863443b-5524-495d-b3ad-74067648f64a",
          "gpa": {
            "currency_code": "USD",
            "ledger_balance": 0,
            "available_balance": 0,
            "credit_balance": 0,
            "pending_credits": 0,
            "balances": {
              "USD": {
                "currency_code": "USD",
                "ledger_balance": 0,
                "available_balance": 0,
                "credit_balance": 0,
                "pending_credits": 0
              }
            }
          },
          "gpa_order": {
            "token": "1a9beb31-a2bf-4c7b-ba52-565b46282e87",
            "amount": 10,
            "created_time": "2022-10-04T00:45:44Z",
            "last_modified_time": "2022-10-04T00:45:44Z",
            "transaction_token": "01a04fe5-dae2-4330-9793-9da2896c05b9",
            "state": "ERROR",
            "response": {
              "code": "1842",
              "memo": "Account load failed"
            },
            "funding": {
              "amount": 10,
              "source": {
                "type": "programgateway",
                "token": "**********3070",
                "name": "hypermatter_funding",
                "active": true,
                "is_default_account": false,
                "created_time": "2022-10-04T00:22:36Z",
                "last_modified_time": "2022-10-04T00:22:36Z"
              },
              "gateway_log": {
                "order_number": "e7e77df5-deb2-4433-b397-40a34a70fd1b",
                "message": "Unable to parse: Hey ya! Great to see you here. Btw, nothing is configured for this request path. Create a rule and start building a mock API.",
                "duration": 470,
                "timed_out": false,
                "response": {
                  "code": "200"
                }
              }
            },
            "funding_source_token": "**********3070",
            "jit_funding": {
              "token": "0aae03fe-d6aa-4357-92cf-61ac92f4f336",
              "method": "pgfs.authorization",
              "user_token": "eb7b0af2-3f00-474d-9a05-611adc8af57d",
              "acting_user_token": "eb7b0af2-3f00-474d-9a05-611adc8af57d",
              "amount": 10
            },
            "user_token": "eb7b0af2-3f00-474d-9a05-611adc8af57d",
            "currency_code": "USD"
          },
          "duration": 973,
          "created_time": "2022-10-04T00:45:43Z",
          "user_transaction_time": "2022-10-04T00:45:43Z",
          "settlement_date": "2022-10-04T00:00:00Z",
          "request_amount": 10,
          "amount": 10,
          "issuer_interchange_amount": 0,
          "currency_code": "USD",
          "response": {
            "code": "1016",
            "memo": "Not sufficient funds"
          },
          "network": "DISCOVER",
          "acquirer_fee_amount": 0,
          "acquirer": {
            "system_trace_audit_number": "523808"
          },
          "user": {
            "metadata": {}
          },
          "card": {
            "last_four": "1903",
            "metadata": {}
          },
          "issuer_received_time": "2022-10-04T00:45:43.810Z",
          "issuer_payment_node": "6e9f8d699bb8de211dde694e995d7011",
          "network_reference_id": "330427851708",
          "card_acceptor": {
            "mid": "11111",
            "mcc": "6411",
            "network_mid": "11111",
            "mcc_groups": [
              "NONE"
            ],
            "name": "Chicken Tooth Music",
            "address": "111 Main St",
            "city": "Berkeley",
            "state": "CA",
            "postal_code": "94702",
            "country": "USA",
            "poi": {
              "partial_approval_capable": "1"
            }
          },
          "is_recurring": false,
          "is_installment": false
        },
        "raw_iso8583": {
          "0": "2110",
          "2": "1111113980391903",
          "3": "000000",
          "4": 10,
          "7": "1004004543",
          "11": "000006523808",
          "12": "20221004004543",
          "13": "221004",
          "14": "2610",
          "15": "20221004",
          "17": "1004",
          "21": "330427851708",
          "22": "10000000020000000100000001000000",
          "24": "181",
          "26": "6411",
          "37": "46295",
          "39": "0051",
          "42": "11111",
          "43": {
            "2": "Chicken Tooth Music",
            "3": "111 Main St",
            "4": "Berkeley",
            "5": "CA",
            "6": "94702",
            "7": "840"
          },
          "44": {
            "1": "Not sufficient funds",
            "2": "Purchase power is just 0.00",
            "3": "51",
            "4": "Not sufficient funds"
          },
          "63": "DISCOVER",
          "112": {
            "22": "0200010000700",
            "103": "840"
          },
          "113": {
            "2": "106",
            "29": "Y",
            "34": "Y",
            "35": "API"
          },
          "180": "ynkffvkq"
        }
      }
    )
    .then( (response) => {
        setIsApproved("DECLINED")
    });



    req.session.set('user', user)
    await req.session.save()
    res.json(user)
  } catch (error) {
    console.error(error)
    const { response: fetchResponse } = error
    res.status(fetchResponse?.status || 500).json(error.data)
  }
})
