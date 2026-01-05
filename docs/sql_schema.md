# KMyMoney SQLite Database Schema Documentation

This document describes the SQLite database schema used by KMyMoney, extracted from source code analysis.

## Overview

The KMyMoney database uses a normalized relational structure to store financial data. The core of the accounting model
is based on **Transactions** (`kmmTransactions`) and **Splits** (`kmmSplits`), implementing a double-entry bookkeeping
system.

**Key Data Types:**

* **Monetary Values (`value`, `shares`, `price`)**: Stored as rational numbers in string format `"numerator/denominator"`
  (e.g., `"100/1"` for 100.00, `"1/10"` for 0.10). This ensures precise arithmetic without floating-point errors.
* **Dates**: stored as `YYYY-MM-DD`.
* **Timestamps**: stored as `YYYY-MM-DDTHH:mm:ss`.
* **Booleans**: Often stored as `char(1)` where `'Y'` is True and `'N'` is False.

## Tables

### kmmFileInfo [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L107)

Stores metadata about the KMyMoney file itself.

* **version** (`varchar(16)`): Database schema version.
* **created** (`date`): Creation date of the file.
* **lastModified** (`date`): Last modification date.
* **baseCurrency** (`char(3)`): The base currency for the file (ISO 4217 code).
* **encryptData** (`varchar(255)`): Holds GPG encryption metadata if the file is encrypted (often just a flag or key
  reference within the application context).
* **logonUser** (`varchar(255)`): User who last opened the file.
* **fixLevel** (`int unsigned`): Fix level version.
* **updateInProgress** (`char(1)`): Flag indicating if an update is in progress.
* **[table]_count** (e.g., `institutions`, `accounts`, `payees`): Cached counts for various tables.
* **hi[Table]Id** (e.g., `hiInstitutionId`, `hiPayeeId`): High-water mark for IDs, used for generating new unique IDs.

### kmmInstitutions [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L123)

Stores details about financial institutions.

* **id** (`varchar(32)`): Unique identifier (PK).
* **name** (`text`): Institution name.
* **manager** (`text`): Relationship manager name.
* **routingCode** (`text`): Bank routing code (e.g., sort code, BLZ).
* **addressStreet**, **addressCity**, **addressZipcode** (`text`): Address details.
* **telephone** (`text`): Contact number.

### kmmAccounts [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L208)

Stores all accounts, including asset, liability, income, expense, and equity accounts.

* **id** (`varchar(32)`): Unique identifier (PK).
* **institutionId** (`varchar(32)`): FK to `kmmInstitutions`.
* **parentId** (`varchar(32)`): FK to parent `kmmAccounts.id` (establishes account hierarchy).
* **accountName** (`text`): Name of the account.
* **accountNumber** (`text`): Account number at the institution.
* **accountType** (`varchar(16)`): Account Type Enum (see table below).
* **accountTypeString** (`text`): Translated/human-readable string for the type (e.g., "Checking", "Savings").
* **currencyId** (`varchar(32)`): FK to `kmmCurrencies.ISOcode` or `kmmSecurities.id`.
* **description** (`text`): User description.
* **openingDate** (`date`): Date account was opened.
* **lastReconciled** (`timestamp`): Date of last reconciliation.
* **lastModified** (`timestamp`): Date of last modification.
* **isStockAccount** (`char(1)`): 'Y' if this is a specialized stock account (sub-account for investment).
* **balance**, **balanceFormatted** (`text`): Cached balance (redundant/performance).
* **transactionCount** (`bigint unsigned`): Cached number of transactions.

#### Account Types (`accountType`)

| Value | Name | Description |
| :--- | :--- | :--- |
| `0` | Unknown | Error handling |
| `1` | Checkings | Standard checking account |
| `2` | Savings | Typical savings account |
| `3` | Cash | Cash in hand |
| `4` | CreditCard | Credit card accounts |
| `5` | Loan | Loan and mortgage accounts (liability) |
| `6` | CertificateDep | Certificates of Deposit |
| `7` | Investment | Investment account |
| `8` | MoneyMarket | Money Market Account |
| `9` | Asset | Generic asset account |
| `10` | Liability | Generic liability account |
| `11` | Currency | Currency trading account |
| `12` | Income | Income account |
| `13` | Expense | Expense account |
| `14` | AssetLoan | Loan (asset of the owner) |
| `15` | Stock | Security account as sub-account for investment |
| `16` | Equity | Equity account |

### kmmTransactions [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L236)

Header table for transactions. A transaction groups multiple splits.

* **id** (`varchar(32)`): Unique identifier (PK).
* **postDate** (`timestamp`): Date the transaction was posted/effective.
* **entryDate** (`timestamp`): Date the transaction was entered into the system.
* **currencyId** (`char(3)`): Transaction currency (commodity).
* **memo** (`text`): General memo for the transaction.
* **bankId** (`text`): External ID from bank import.
* **txType** (`char(1)`):
  * `'N'`: Normal transaction.
  * `'S'`: Scheduled transaction pattern (template).

### kmmSplits [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L263)

Stores the actual value movements. A transaction consists of 2 or more splits.

* **transactionId** (`varchar(32)`): FK to `kmmTransactions`.
* **splitId** (`smallint unsigned`): Index of the split within the transaction (0-based).
* **accountId** (`varchar(32)`): FK to `kmmAccounts`.
* **payeeId** (`varchar(32)`): FK to `kmmPayees`.
* **value** (`text`): The amount in the **transaction's currency** (format: "num/denom").
* **shares** (`text`): The amount in the **account's currency/shares** (format: "num/denom").
* **price** (`text`): Price per share (shares * price ~= value).
* **memo** (`text`): Memo specific to this split.
* **action** (`varchar(16)`): Activity type (see table below).
* **reconcileFlag** (`char(1)`):
  * `'0'` / `'n'`: Not Reconciled
  * `'1'` / `'c'`: Cleared
  * `'2'` / `'y'`: Reconciled
  * `'3'` / `'f'`: Frozen
* **reconcileDate** (`timestamp`): Date reconciled.
* **checkNumber** (`varchar(32)`): Check number.
* **costCenterId** (`varchar(32)`): FK to `kmmCostCenter`.
* **bankId** (`mediumtext`): External ID for the split.
* **txType** (`char(1)`): Redundant with transaction header ('N' or 'S').

#### Split Actions (`action`)

These map to `eMyMoney::Split::Action`.

| Database String | Meaning |
| :--- | :--- |
| `ATM` | ATM Withdrawal |
| `Add` | Add Shares |
| `Amortization` | Loan Amortization |
| `Buy` | Buy Shares |
| `Check` | Check |
| `Deposit` | Deposit |
| `Dividend` | Dividend |
| `Interest` | Interest Expense |
| `IntIncome` | Interest Income |
| `Reinvest` | Reinvest Dividend |
| `Split` | Split Shares (Stock Split) |
| `Transfer` | Transfer |
| `Withdrawal` | Withdrawal |
| `Yield` | Yield |

### kmmPayees [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L147)

Stores payees (people or organizations).

* **id** (`varchar(32)`): Unique identifier (PK).
* **name** (`text`): Payee name.
* **defaultAccountId** (`varchar(32)`): Default category/account for this payee.
* **matchData** (`tinyint unsigned`): `eMyMoney::Payee::MatchType` (0=Disabled, 1=Name, 2=Key, 3=NameExact).
* **matchIgnoreCase** (`char(1)`): 'Y'/'N'.
* **matchKeys** (`mediumtext`): List of keys for matching.
* **idPattern** (`text`): Regex pattern for ID matching.
* **address***, **email**, **telephone**, **notes**: Contact info.

### kmmSchedules [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L310)

Stores scheduled transactions (recurring payments).

* **id** (`varchar(32)`): Unique identifier (PK).
* **name** (`text`): Schedule name.
* **type** (`tinyint unsigned`): `eMyMoney::Schedule::Type`.
  * `1`: Bill
  * `2`: Deposit
  * `4`: Transfer
  * `5`: LoanPayment
* **occurence** (`smallint unsigned`): `eMyMoney::Schedule::Occurrence`.
  * `1`: Once, `2`: Daily, `4`: Weekly, `8`: Fortnightly, `32`: Monthly, ... `16384`: Yearly.
* **occurenceMultiplier** (`smallint unsigned`): Multiplier (e.g., *2* weeks).
* **paymentType** (`tinyint unsigned`): `eMyMoney::Schedule::PaymentType` (1=DirectDebit, 2=DirectDeposit,
  4=ManualDeposit, etc.).
* **weekendOption** (`tinyint unsigned`): `eMyMoney::Schedule::WeekendOption` (0=MoveBefore, 1=MoveAfter, 2=MoveNothing).
* **startDate**, **endDate**, **nextPaymentDue**, **lastPayment** (`date`).
* **fixed** (`char(1)`): 'Y' if amount is fixed.
* **autoEnter** (`char(1)`): 'Y' if should auto-enter.

### kmmSecurities [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L338)

Stores definitions for stocks, mutual funds, etc.

* **id** (`varchar(32)`): Unique identifier (PK).
* **name** (`text`): Security name.
* **symbol** (`text`): Ticker symbol.
* **type** (`smallint unsigned`): `eMyMoney::Security::Type`.
  * `0`: Stock
  * `1`: Mutual Fund
  * `2`: Bond
  * `3`: Currency
  * `4`: None
* **tradingCurrency** (`char(3)`): Currency the security is traded in.
* **pricePrecision** (`smallint unsigned`): Decimal places for price.
* **roundingMethod** (`smallint unsigned`): e.g., 7 (RoundRound).

### kmmPrices [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L352)

Stores historical prices.

* **fromId** (`varchar(32)`): Security/Currency ID.
* **toId** (`varchar(32)`): Measurement currency ID.
* **priceDate** (`date`): Date of price.
* **price** (`text`): Value (num/denom).
* **priceSource** (`text`): Source (e.g., "User", "Online").

### Other Tables

#### kmmTags [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L173)

Tags for categorization.

* **id** (`varchar(32)`): PK.
* **name** (`text`): Tag Name.
* **closed** (`char(1)`): 'Y' if closed.
* **tagColor** (`text`): Color hex code.

#### kmmTagSplits [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L184)

Many-to-many link between Splits and Tags.

* **transactionId**, **tagId**, **splitId**: Composite PK.

#### kmmKeyValuePairs [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L278)

Generic key-value storage for extensible attributes attached to objects.

* **kvpType** (`varchar(16)`): valid values include `"ACCOUNT"`, `"TRANSACTION"`, `"SPLIT"`, `"PAYEE"`, `"SCHEDULE"`,
  `"SECURITY"`, `"INSTITUTION"`, `"TAG"`, `"STORAGE"` (file info).
* **kvpId** (`varchar(32)`): ID of the owning object.
* **kvpKey** (`varchar(255)`): Key name (e.g., "kmm-online-provider").
* **kvpData** (`text`): Value.

#### kmmOnlineJobs [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L399)

Queue for online banking tasks.

* **id** (`varchar(32)`): PK.
* **type** (`varchar(255)`): Task type ID.
* **state** (`varchar(15)`): Status (`acceptedByBank`, `rejectedByBank`, `abortedByUser`, `sendingError`, `noBankAnswer`).
* **locked** (`char(1)`): 'Y' if locked.

#### kmmPayeeIdentifier [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L411) / kmmPayeesPayeeIdentifier [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L159)

Stores banking identifiers linked to payees, allowing for automated matching during import.

* **kmmPayeeIdentifier**:
  * **id** (`varchar(32)`): Unique identifier (PK).
  * **type** (`varchar(255)`): The identifier plugin type. Common values:
    * `org.kmymoney.payeeIdentifier.ibanbic`: IBAN/BIC.
    * `org.kmymoney.payeeIdentifier.national`: National account number + bank code.
* **kmmPayeesPayeeIdentifier**: Link table between Payees and Identifiers.
  * **payeeId** (`varchar(32)`): FK to `kmmPayees`.
  * **payeeIdentifierId** (`varchar(32)`): FK to `kmmPayeeIdentifier`.

**Identifier Data Storage**:
The actual data for the identifier (e.g., the IBAN string) is stored in the **`kmmKeyValuePairs`** table.

* **kvpId**: Matches `kmmPayeeIdentifier.id`.
* **kvpType**: `PAYEEIDENTIFIER` (or similar).
* **kvpKey**: Field name.
  * For `ibanbic`: `iban`, `bic`, `ownerName`.
  * For `national`: `bankCode`, `accountNumber`, `country`, `ownerName`.

#### kmmReports [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L383) / kmmBudgets [Src](file:///home/juanfran/workspace/merlin/external/kmymoney/kmymoney/plugins/sql/mymoneydbdef.cpp#L437)

Store configuration for reports and budgets. These tables use a hybrid relational/XML approach. Top-level metadata
might be in columns or just in the XML.

* **id**: Unique identifier.
* **XML**: Contains the full serialized object configuration.
  * **Reports (`kmmReports`)**: Root element `<REPORT>`. Attributes include `name`, `type`, `group`, `datelock` (date
    filter), `convertcurrency`. Child elements define filters (`<ACCOUNT>`, `<PAYEE>`, `<TAG>`, `<CATEGORY>`) and
    display settings.
  * **Budgets (`kmmBudgets`)**: Root element `<BUDGET>`. Attributes include `name`, `start` (date), `budgetlevel`
    (e.g., `monthly`, `yearly`). Child elements `<ACCOUNT>` contain `<PERIOD>` elements defining budgeted amounts for
    specific timeframes.
