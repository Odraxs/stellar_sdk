defmodule Stellar.TxBuild.Validations do
  @moduledoc """
  Ensures that child components/structures used by operations are properly initialized otherwise, returns a formatted error.
  """

  alias Stellar.TxBuild.{
    Account,
    AccountID,
    Amount,
    Asset,
    AssetsPath,
    Flags,
    ClaimableBalanceID,
    OptionalAccount,
    OptionalAccountID,
    OptionalFlags,
    OptionalWeight,
    OptionalSigner,
    OptionalString32,
    PoolID,
    Price,
    SequenceNumber,
    Signer,
    String32,
    Weight,
    SCAddress,
    SCVal,
    SCVec
  }

  @type account_id :: String.t()
  @type asset_code :: String.t()
  @type args :: list(SCVal.t())
  @type asset :: {asset_code(), account_id()} | Keyword.t() | atom()
  @type value :: account_id() | asset() | number() | args()
  @type component :: {atom(), value()}
  @type error :: Keyword.t() | atom()
  @type validation :: {:ok, any()} | {:error, error()}

  @spec is_struct?(term :: any(), name :: module()) :: boolean()
  def is_struct?(term, name) when is_struct(term) and is_atom(name), do: term.__struct__ == name
  def is_struct?(_term, _name), do: false

  @spec validate_pos_integer(component :: component()) :: validation()
  def validate_pos_integer({_field, number}) when is_integer(number) and number >= 0,
    do: {:ok, number}

  def validate_pos_integer({field, _number}), do: {:error, [{field, :integer_expected}]}

  @spec validate_account_id(component :: component()) :: validation()
  def validate_account_id({field, account_id}) do
    case AccountID.new(account_id) do
      %AccountID{} = account_id -> {:ok, account_id}
      {:error, reason} -> {:error, [{field, reason}]}
    end
  end

  @spec validate_optional_account_id(component :: component()) :: validation()
  def validate_optional_account_id({_field, nil}), do: {:ok, OptionalAccountID.new()}

  def validate_optional_account_id({field, account_id}) do
    with {:ok, _account} <- validate_account_id({field, account_id}) do
      {:ok, OptionalAccountID.new(account_id)}
    end
  end

  @spec validate_account(component :: component()) :: validation()
  def validate_account({field, account}) do
    case Account.new(account) do
      %Account{} = account -> {:ok, account}
      {:error, reason} -> {:error, [{field, reason}]}
    end
  end

  @spec validate_optional_account(component :: component()) :: validation()
  def validate_optional_account({_field, nil}), do: {:ok, OptionalAccount.new()}

  def validate_optional_account({field, account_id}) do
    with {:ok, _account} <- validate_account({field, account_id}) do
      {:ok, OptionalAccount.new(account_id)}
    end
  end

  @spec validate_asset(component :: component()) :: validation()
  def validate_asset({field, asset}) do
    case Asset.new(asset) do
      %Asset{} = asset -> {:ok, asset}
      {:error, reason} -> {:error, [{field, reason}]}
    end
  end

  @spec validate_optional_assets_path(component :: component()) :: validation()
  def validate_optional_assets_path({_field, nil}), do: {:ok, AssetsPath.new()}

  def validate_optional_assets_path({field, assets}) do
    case AssetsPath.new(assets) do
      %AssetsPath{} = assets -> {:ok, assets}
      {:error, reason} -> {:error, [{field, reason}]}
    end
  end

  @spec validate_amount(component :: component()) :: validation()
  def validate_amount({field, amount}) do
    case Amount.new(amount) do
      %Amount{} = amount -> {:ok, amount}
      {:error, reason} -> {:error, [{field, reason}]}
    end
  end

  @spec validate_optional_amount(component :: component()) :: validation()
  def validate_optional_amount({_field, nil}), do: {:ok, Amount.new(:max)}

  def validate_optional_amount({field, value}) do
    validate_amount({field, value})
  end

  @spec validate_price(component :: component()) :: validation()
  def validate_price({field, price}) do
    case Price.new(price) do
      %Price{} = price -> {:ok, price}
      {:error, reason} -> {:error, [{field, reason}]}
    end
  end

  @spec validate_claimable_balance_id(component :: component()) :: validation()
  def validate_claimable_balance_id({field, balance_id}) do
    case ClaimableBalanceID.new(balance_id) do
      %ClaimableBalanceID{} = claimable_balance_id -> {:ok, claimable_balance_id}
      {:error, reason} -> {:error, [{field, reason}]}
    end
  end

  @spec validate_pool_id(component :: component()) :: validation()
  def validate_pool_id({field, pool_id}) do
    case PoolID.new(pool_id) do
      %PoolID{} = pool_id -> {:ok, pool_id}
      {:error, reason} -> {:error, [{field, reason}]}
    end
  end

  @spec validate_optional_flags(component :: component()) :: validation()
  def validate_optional_flags({_field, nil}), do: {:ok, OptionalFlags.new()}

  def validate_optional_flags({field, value}) do
    case Flags.new(value) do
      %Flags{} = flags -> {:ok, OptionalFlags.new(flags)}
      {:error, reason} -> {:error, [{field, reason}]}
    end
  end

  @spec validate_optional_weight(component :: component()) :: validation()
  def validate_optional_weight({_field, nil}), do: {:ok, OptionalWeight.new()}

  def validate_optional_weight({field, value}) do
    case Weight.new(value) do
      %Weight{} = weight -> {:ok, OptionalWeight.new(weight)}
      {:error, reason} -> {:error, [{field, reason}]}
    end
  end

  @spec validate_optional_string32(component :: component()) :: validation()
  def validate_optional_string32({_field, nil}), do: {:ok, OptionalString32.new()}

  def validate_optional_string32({field, value}) do
    case String32.new(value) do
      %String32{} = str -> {:ok, OptionalString32.new(str)}
      {:error, reason} -> {:error, [{field, reason}]}
    end
  end

  @spec validate_optional_signer(component :: component()) :: validation()
  def validate_optional_signer({_field, nil}), do: {:ok, OptionalSigner.new()}

  def validate_optional_signer({field, value}) do
    case Signer.new(value) do
      %Signer{} = signer -> {:ok, OptionalSigner.new(signer)}
      {:error, reason} -> {:error, [{field, reason}]}
    end
  end

  @spec validate_sc_vals(component :: component()) :: validation()
  def validate_sc_vals({field, args}) when is_list(args) do
    if Enum.all?(args, &is_struct?(&1, SCVal)),
      do: {:ok, args},
      else: {:error, :"invalid_#{field}"}
  end

  def validate_sc_vals({field, _args}), do: {:error, :"invalid_#{field}"}

  @spec validate_contract_id(component :: component()) :: validation()
  def validate_contract_id({field, contract_id}) when is_binary(contract_id) do
    case Base.decode16(contract_id, case: :lower) do
      {:ok, _} -> {:ok, contract_id}
      :error -> {:error, :"invalid_#{field}"}
    end
  end

  def validate_contract_id({field, _contract_id}), do: {:error, :"invalid_#{field}"}

  @spec validate_string(tuple()) :: validation()
  def validate_string({_type, string}) when is_binary(string), do: {:ok, string}
  def validate_string({type, _string}), do: {:error, :"invalid_#{type}"}

  @spec validate_sequence_number(tuple()) :: validation()
  def validate_sequence_number({_field, %SequenceNumber{} = value}),
    do: {:ok, value}

  def validate_sequence_number({field, _}), do: {:error, :"invalid_#{field}"}

  @spec validate_address(address :: SCAddress.t()) :: validation()
  def validate_address(%SCAddress{} = address), do: {:ok, address}

  def validate_address(_address), do: {:error, :invalid_address}

  @spec validate_vec(args :: SCVec.t()) :: validation()
  def validate_vec(%SCVec{} = args), do: {:ok, args}
  def validate_vec(_args), do: {:error, :invalid_args}
end
