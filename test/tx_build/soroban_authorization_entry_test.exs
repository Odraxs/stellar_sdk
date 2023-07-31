defmodule Stellar.TxBuild.SorobanAuthorizationEntryTest do
  use ExUnit.Case

  alias Stellar.TxBuild.{
    SCAddress,
    SCMapEntry,
    SCVal,
    SCVec,
    SorobanAddressCredentials,
    SorobanAuthorizedInvocation,
    SorobanAuthorizedFunction,
    SorobanAuthorizedContractFunction,
    SorobanAuthorizationEntry,
    SorobanCredentials
  }

  setup do
    fn_args = SCVec.new([SCVal.new(symbol: "dev")])

    contract_address = SCAddress.new("CBT6AP4HS575FETHYO6CMIZ2NUFPLKC7JGO7HNBEDTPLZJADT5RDRZP4")

    function_name = "hello"

    contract_fn =
      SorobanAuthorizedContractFunction.new(
        contract_address: contract_address,
        function_name: function_name,
        args: fn_args
      )

    soroban_function = SorobanAuthorizedFunction.new(contract_fn: contract_fn)

    root_invocation =
      SorobanAuthorizedInvocation.new(function: soroban_function, sub_invocations: [])

    credentials = SorobanCredentials.new(source_account: nil)

    soroban_auth_entry =
      SorobanAuthorizationEntry.new(credentials: credentials, root_invocation: root_invocation)

    xdr = %StellarBase.XDR.SorobanAuthorizationEntry{
      credentials: %StellarBase.XDR.SorobanCredentials{
        value: %StellarBase.XDR.Void{value: nil},
        type: %StellarBase.XDR.SorobanCredentialsType{
          identifier: :SOROBAN_CREDENTIALS_SOURCE_ACCOUNT
        }
      },
      root_invocation: %StellarBase.XDR.SorobanAuthorizedInvocation{
        function: %StellarBase.XDR.SorobanAuthorizedFunction{
          value: %StellarBase.XDR.SorobanAuthorizedContractFunction{
            contract_address: %StellarBase.XDR.SCAddress{
              sc_address: %StellarBase.XDR.Hash{
                value:
                  <<103, 224, 63, 135, 151, 127, 210, 146, 103, 195, 188, 38, 35, 58, 109, 10,
                    245, 168, 95, 73, 157, 243, 180, 36, 28, 222, 188, 164, 3, 159, 98, 56>>
              },
              type: %StellarBase.XDR.SCAddressType{identifier: :SC_ADDRESS_TYPE_CONTRACT}
            },
            function_name: %StellarBase.XDR.SCSymbol{value: "hello"},
            args: %StellarBase.XDR.SCVec{
              items: [
                %StellarBase.XDR.SCVal{
                  value: %StellarBase.XDR.SCSymbol{value: "dev"},
                  type: %StellarBase.XDR.SCValType{identifier: :SCV_SYMBOL}
                }
              ]
            }
          },
          type: %StellarBase.XDR.SorobanAuthorizedFunctionType{
            identifier: :SOROBAN_AUTHORIZED_FUNCTION_TYPE_CONTRACT_FN
          }
        },
        sub_invocations: %StellarBase.XDR.SorobanAuthorizedInvocationList{items: []}
      }
    }

    address = SCAddress.new("GDEU46HFMHBHCSFA3K336I3MJSBZCWVI3LUGSNL6AF2BW2Q2XR7NNAPM")
    nonce = 1_078_069_780
    signature_expiration_ledger = 164_080

    soroban_address_credentials =
      SorobanAddressCredentials.new(
        address: address,
        nonce: nonce,
        signature_expiration_ledger: signature_expiration_ledger,
        signature_args: SCVec.new([])
      )

    address_credentials = SorobanCredentials.new(address: soroban_address_credentials)

    soroban_auth_entry_with_address_credentials =
      SorobanAuthorizationEntry.new(
        credentials: address_credentials,
        root_invocation: root_invocation
      )

    %{
      credentials: credentials,
      root_invocation: root_invocation,
      soroban_auth_entry: soroban_auth_entry,
      xdr: xdr,
      base_64:
        "AAAAAQAAAAAAAAAAyU545WHCcUig2re/I2xMg5FaqNroaTV+AXQbahq8ftY69WqNb/7SRQAAAAAAAAAAAAAAAAAAAAEYaWENrVfrP3DtntX8suGy/f52r9ikRgXsGYWrbdStxwAAAANpbmMAAAAAAgAAABIAAAAAAAAAAMlOeOVhwnFIoNq3vyNsTIORWqja6Gk1fgF0G2oavH7WAAAACQAAAAAAAAAAAAAAAAAAAAIAAAAA",
      secret_key: "SCAVFA3PI3MJLTQNMXOUNBSEUOSY66YMG3T2KCQKLQBENNVLVKNPV3EK",
      latest_ledger: 164_256,
      sign_xdr:
        "AAAAAQAAAAAAAAAAyU545WHCcUig2re/I2xMg5FaqNroaTV+AXQbahq8ftY69WqNb/7SRQACgaMAAAABAAAAEQAAAAEAAAACAAAADwAAAApwdWJsaWNfa2V5AAAAAAANAAAAIMlOeOVhwnFIoNq3vyNsTIORWqja6Gk1fgF0G2oavH7WAAAADwAAAAlzaWduYXR1cmUAAAAAAAANAAAAQOdgROP+0omN51SCii/Ttcy5PhyPfGIaPWG4FBvQNEp1jGMio+lH5IKE5boB5dvdbR0wNixWSHXZBb/35hyftAIAAAAAAAAAARhpYQ2tV+s/cO2e1fyy4bL9/nav2KRGBewZhatt1K3HAAAAA2luYwAAAAACAAAAEgAAAAAAAAAAyU545WHCcUig2re/I2xMg5FaqNroaTV+AXQbahq8ftYAAAAJAAAAAAAAAAAAAAAAAAAAAgAAAAA=",
      soroban_auth_entry_with_address_credentials: soroban_auth_entry_with_address_credentials
    }
  end

  test "new/2", %{credentials: credentials, root_invocation: root_invocation} do
    %SorobanAuthorizationEntry{
      credentials: ^credentials,
      root_invocation: ^root_invocation
    } = SorobanAuthorizationEntry.new(credentials: credentials, root_invocation: root_invocation)
  end

  test "new/2 with invalid credentials", %{root_invocation: root_invocation} do
    {:error, :invalid_credentials} =
      SorobanAuthorizationEntry.new(credentials: :invalid, root_invocation: root_invocation)
  end

  test "new/2 with invalid root_invocation", %{credentials: credentials} do
    {:error, :invalid_root_invocation} =
      SorobanAuthorizationEntry.new(credentials: credentials, root_invocation: :invalid)
  end

  test "new/2 with invalid args" do
    {:error, :invalid_auth_entry_args} = SorobanAuthorizationEntry.new(:invalid)
  end

  test "sign/2", %{
    soroban_auth_entry_with_address_credentials: soroban_auth_entry_with_address_credentials,
    root_invocation: root_invocation,
    secret_key: secret_key
  } do
    %SorobanAuthorizationEntry{
      credentials: %SorobanAddressCredentials{
        signature_args: %SCVec{
          items: [
            %SCVal{
              type: :map,
              value: [
                %SCMapEntry{
                  key: %SCVal{type: :symbol, value: "public_key"},
                  val: %SCVal{
                    type: :bytes,
                    value:
                      <<201, 78, 120, 229, 97, 194, 113, 72, 160, 218, 183, 191, 35, 108, 76, 131,
                        145, 90, 168, 218, 232, 105, 53, 126, 1, 116, 27, 106, 26, 188, 126, 214>>
                  }
                },
                %SCMapEntry{
                  key: %SCVal{type: :symbol, value: "signature"},
                  val: %SCVal{
                    type: :bytes,
                    value:
                      <<150, 185, 157, 21, 98, 125, 110, 204, 42, 246, 50, 2, 183, 10, 131, 52,
                        104, 227, 126, 242, 21, 38, 240, 255, 85, 41, 141, 68, 84, 109, 83, 40,
                        85, 45, 189, 166, 230, 247, 130, 33, 7, 98, 206, 245, 60, 171, 182, 42,
                        10, 185, 218, 200, 114, 119, 66, 120, 20, 170, 133, 131, 105, 148, 91,
                        14>>
                  }
                }
              ]
            }
          ]
        }
      },
      root_invocation: ^root_invocation
    } = SorobanAuthorizationEntry.sign(soroban_auth_entry_with_address_credentials, secret_key)
  end

  test "sign/2 invalid secret_key", %{
    soroban_auth_entry_with_address_credentials: soroban_auth_entry_with_address_credentials
  } do
    {:error, :invalid_sign_args} =
      SorobanAuthorizationEntry.sign(soroban_auth_entry_with_address_credentials, :secret_key)
  end

  test "sign_xdr/3", %{
    base_64: base_64,
    secret_key: secret_key,
    latest_ledger: latest_ledger,
    sign_xdr: sign_xdr
  } do
    ^sign_xdr = SorobanAuthorizationEntry.sign_xdr(base_64, secret_key, latest_ledger)
  end

  test "sign_xdr/3 invalid secret_key", %{base_64: base_64, latest_ledger: latest_ledger} do
    {:error, :invalid_sign_args} =
      SorobanAuthorizationEntry.sign_xdr(base_64, :secret_key, latest_ledger)
  end

  test "to_xdr/1", %{soroban_auth_entry: soroban_auth_entry, xdr: xdr} do
    ^xdr = SorobanAuthorizationEntry.to_xdr(soroban_auth_entry)
  end

  test "to_xdr/1 error" do
    {:error, :invalid_struct} = SorobanAuthorizationEntry.to_xdr(:invalid)
  end
end
