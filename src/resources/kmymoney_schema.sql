-- KMyMoney SQLite Schema
-- Extracted from source code analysis of MyMoneyDbDef::MyMoneyDbDef() and related methods

CREATE TABLE kmmFileInfo (
    version varchar(16),
    created date,
    lastModified date,
    baseCurrency char(3),
    institutions bigint unsigned,
    accounts bigint unsigned,
    payees bigint unsigned,
    tags bigint unsigned,
    transactions bigint unsigned,
    splits bigint unsigned,
    securities bigint unsigned,
    prices bigint unsigned,
    currencies bigint unsigned,
    schedules bigint unsigned,
    reports bigint unsigned,
    kvps bigint unsigned,
    dateRangeStart date,
    dateRangeEnd date,
    hiInstitutionId bigint unsigned,
    hiPayeeId bigint unsigned,
    hiTagId bigint unsigned,
    hiAccountId bigint unsigned,
    hiTransactionId bigint unsigned,
    hiScheduleId bigint unsigned,
    hiSecurityId bigint unsigned,
    hiReportId bigint unsigned,
    encryptData varchar(255),
    updateInProgress char(1),
    budgets bigint unsigned,
    hiBudgetId bigint unsigned,
    hiOnlineJobId bigint unsigned,
    hiPayeeIdentifierId bigint unsigned,
    logonUser varchar(255),
    logonAt timestamp,
    fixLevel int unsigned
);

CREATE TABLE kmmInstitutions (
    id varchar(32) NOT NULL,
    name text NOT NULL,
    manager text,
    routingCode text,
    addressStreet text,
    addressCity text,
    addressZipcode text,
    telephone text,
    PRIMARY KEY (id)
);

CREATE TABLE kmmPayees (
    id varchar(32) NOT NULL,
    name text,
    reference text,
    email text,
    addressStreet text,
    addressCity text,
    addressZipcode text,
    addressState text,
    telephone text,
    notes longtext,
    defaultAccountId varchar(32),
    matchData tinyint unsigned,
    matchIgnoreCase char(1),
    matchKeys mediumtext,
    idPattern text,
    urlTemplate text,
    PRIMARY KEY (id)
);

CREATE TABLE kmmPayeesPayeeIdentifier (
    payeeId varchar(32) NOT NULL,
    userOrder smallint unsigned NOT NULL,
    identifierId varchar(32) NOT NULL,
    PRIMARY KEY (payeeId, userOrder)
);

CREATE TABLE kmmTags (
    id varchar(32) NOT NULL,
    name text,
    closed char(1),
    notes longtext,
    tagColor text,
    PRIMARY KEY (id)
);

CREATE TABLE kmmTagSplits (
    transactionId varchar(32) NOT NULL,
    tagId varchar(32) NOT NULL,
    splitId smallint unsigned NOT NULL,
    PRIMARY KEY (transactionId, tagId, splitId)
);

CREATE TABLE kmmAccounts (
    id varchar(32) NOT NULL,
    institutionId varchar(32),
    parentId varchar(32),
    lastReconciled timestamp,
    lastModified timestamp,
    openingDate date,
    accountNumber text,
    accountType varchar(16) NOT NULL,
    accountTypeString text,
    isStockAccount char(1),
    accountName text,
    description text,
    currencyId varchar(32),
    balance text,
    balanceFormatted text,
    transactionCount bigint unsigned,
    PRIMARY KEY (id)
);

CREATE TABLE kmmAccountsPayeeIdentifier (
    accountId varchar(32) NOT NULL,
    userOrder smallint unsigned NOT NULL,
    identifierId varchar(32) NOT NULL,
    PRIMARY KEY (accountId, userOrder)
);

CREATE TABLE kmmTransactions (
    id varchar(32) NOT NULL,
    txType char(1),
    postDate timestamp,
    memo text,
    entryDate timestamp,
    currencyId char(3),
    bankId text,
    PRIMARY KEY (id)
);

CREATE TABLE kmmSplits (
    transactionId varchar(32) NOT NULL,
    txType char(1),
    splitId smallint unsigned NOT NULL,
    payeeId varchar(32),
    reconcileDate timestamp,
    action varchar(16),
    reconcileFlag char(1),
    value text NOT NULL,
    valueFormatted text,
    shares text NOT NULL,
    sharesFormatted text,
    price text,
    priceFormatted mediumtext,
    memo text,
    accountId varchar(32) NOT NULL,
    costCenterId varchar(32),
    checkNumber varchar(32),
    postDate timestamp,
    bankId mediumtext,
    PRIMARY KEY (transactionId, splitId)
);
CREATE INDEX kmmSplits_kmmSplitsaccount_type_idx ON kmmSplits (accountId, txType);

CREATE TABLE kmmKeyValuePairs (
    kvpType varchar(16) NOT NULL,
    kvpId varchar(32),
    kvpKey varchar(255) NOT NULL,
    kvpData text
);
CREATE INDEX kmmKeyValuePairs_type_id_idx ON kmmKeyValuePairs (kvpType, kvpId);

CREATE TABLE kmmSchedules (
    id varchar(32) NOT NULL,
    name text NOT NULL,
    type tinyint unsigned NOT NULL,
    typeString text,
    occurence smallint unsigned NOT NULL,
    occurenceMultiplier smallint unsigned NOT NULL,
    occurenceString text,
    paymentType tinyint unsigned,
    paymentTypeString longtext,
    startDate date NOT NULL,
    endDate date,
    fixed char(1) NOT NULL,
    lastDayInMonth char(1) NOT NULL DEFAULT 'N',
    autoEnter char(1) NOT NULL,
    lastPayment date,
    nextPaymentDue date,
    weekendOption tinyint unsigned NOT NULL,
    weekendOptionString text,
    PRIMARY KEY (id)
);

CREATE TABLE kmmSchedulePaymentHistory (
    schedId varchar(32) NOT NULL,
    payDate date NOT NULL,
    PRIMARY KEY (schedId, payDate)
);

CREATE TABLE kmmSecurities (
    id varchar(32) NOT NULL,
    name text NOT NULL,
    symbol text,
    type smallint unsigned NOT NULL,
    typeString text,
    smallestAccountFraction varchar(24),
    pricePrecision smallint unsigned NOT NULL DEFAULT 4,
    tradingMarket text,
    tradingCurrency char(3),
    roundingMethod smallint unsigned NOT NULL DEFAULT 7, -- AlkValue::RoundRound probably maps to 7 or similar enum value
    PRIMARY KEY (id)
);

CREATE TABLE kmmPrices (
    fromId varchar(32) NOT NULL,
    toId varchar(32) NOT NULL,
    priceDate date NOT NULL,
    price text NOT NULL,
    priceFormatted text,
    priceSource text,
    PRIMARY KEY (fromId, toId, priceDate)
);

CREATE TABLE kmmCurrencies (
    ISOcode char(3) NOT NULL,
    name text NOT NULL,
    type smallint unsigned,
    typeString text,
    symbol1 smallint unsigned,
    symbol2 smallint unsigned,
    symbol3 smallint unsigned,
    symbolString varchar(255),
    smallestCashFraction varchar(24),
    smallestAccountFraction varchar(24),
    pricePrecision smallint unsigned NOT NULL DEFAULT 4,
    PRIMARY KEY (ISOcode)
);

CREATE TABLE kmmReportConfig (
    name varchar(255) NOT NULL,
    XML longtext,
    id varchar(32) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE kmmOnlineJobs (
    id varchar(32) NOT NULL,
    type varchar(255) NOT NULL,
    jobSend timestamp,
    bankAnswerDate timestamp,
    state varchar(15) NOT NULL,
    locked char(1) NOT NULL,
    PRIMARY KEY (id)
);

CREATE TABLE kmmPayeeIdentifier (
    id varchar(32) NOT NULL,
    type varchar(255),
    PRIMARY KEY (id)
);

CREATE TABLE kmmPluginInfo (
    iid varchar(255) NOT NULL,
    versionMajor tinyint NOT NULL,
    versionMinor tinyint,
    uninstallQuery longtext,
    PRIMARY KEY (iid)
);

CREATE TABLE kmmBudgetConfig (
    id varchar(32) NOT NULL,
    name text NOT NULL,
    start date NOT NULL,
    XML longtext,
    PRIMARY KEY (id)
);

CREATE TABLE kmmCostCenter (
    id varchar(32) NOT NULL,
    name text NOT NULL,
    PRIMARY KEY (id)
);

CREATE VIEW kmmBalances AS SELECT kmmAccounts.id AS id, kmmAccounts.currencyId, kmmSplits.txType, kmmSplits.value, kmmSplits.shares, kmmSplits.postDate AS balDate, kmmTransactions.currencyId AS txCurrencyId FROM kmmAccounts, kmmSplits, kmmTransactions WHERE kmmSplits.txType = 'N' AND kmmSplits.accountId = kmmAccounts.id AND kmmSplits.transactionId = kmmTransactions.id;
