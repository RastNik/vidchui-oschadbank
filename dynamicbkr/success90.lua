#!/bin/lua

local eos = '\r\n';
local eoss = '\t';

-- Check not empty string local function
local function is_not_empty(s)
  return s ~= nil and s ~= ''
end
-- Check empty string local function
local function is_empty(s)
  return s == nil or s == ''
end
----------------------------------------------------------------------
-- Helper function format datetime
----------------------------------------------------------------------
local function format_datetime(val)
    if (val) then
        local xyear,xmonth,xday,xhour,xmin,xsec = val:match("^(%d%d%d%d)(%d%d)(%d%d)(%d%d)(%d%d)(%d%d)$");
        return xyear..'.'..xmonth..'.'..xday..' '..xhour..':'..xmin..':'..xsec;
    end
    return nil;
end

local tran_date = format_datetime(ctx:valget(9)); -- Transaction date

----------------------------------------------------------------------
-- Available action code values:
----------------------------------------------------------------------
--   [0]  -  Transaction success
--   [1]  -  Duplicate transaction
--   [2]  -  Transaction was declined
--   [3]  -  Transaction error
--   [4]  -  Transaction information (deprecated)
--   [5]  -  3D-Secure response from issuer side
--   [6]  -  Duplicate decline transaction
--   [7]  -  Duplicate authentication error transaction
--   [8]  -  Duplicate no response transaction
--   [9]  -  MasterCard transaction installment
--   [10] -  Verify cardholder by OTP authentication code
--   [11] -  Verify cardholder by generated random amount
--   [12] -  MasterCard transaction installment auto cancelled
--   [13] -  MasterCard transaction installment auto full payment
--   [14] -  MasterCard transaction installment user cancelled
--   [15] -  China Union pay request
--   [16] -  User confirmation request
--   [17] -  User transaction form request
----------------------------------------------------------------------
local action_code = ctx:valget(1)  -- Action code

----------------------------------------------------------------------
-- Available result code values:
----------------------------------------------------------------------
--  [00]  -  Transaction success
--  [-1]  -  Missing incoming CGI values
--  [-2]  -  Bad CGI request
--  [-3]  -  No or Invalid response received from TS(NS) server side
--  [-4]  -  Server is not responding TS(NS)
--  [-5]  -  Connection failed TS(NS)
--  [-6]  -  Invalid configuration
--  [-7]  -  Invalid response from TS(NS) server side
--  [-8]  -  Invalid card CGI field
--  [-9]  -  Invalid expiration date CGI field
--  [-10] -  Invalid amount CGI field
--  [-11] -  Invalid currency CGI field
--  [-12] -  Error in merchant terminal field
--  [-13] -  Unknown referer (deprecated)
--  [-14] -  PINpad agent/device error
--  [-15] -  Invalid Retrieval reference number (reference base transactions)
--  [-16] -  Terminal is locked
--  [-17] -  Access denied
--  [-18] -  Error in CVC2 or CVC2 Description fields
--  [-19] -  Authentication failed
--  [-20] -  Expired transaction
--  [-21] -  Duplicate transaction
--  [-22] -  Error in authentication info
--  [-23] -  Invalid transaction context
--  [-24] -  Transaction context data mismatch
--  [-25] -  Transaction was canceled by user
--  [-26] -  Invalid BIN, not used in action
--  [-27] -  Invalid merchant name (Used in payment facilitator)
--  [-28] -  Invalid addendum format/script
--  [-29] -  Invalid/duplicate authentication reference
--  [-30] -  Decline by fraud
--  [-31] -  Transaction already in progress
--  [-32] -  Duplicate authentication decline
--  [-33] -  Transaction in authentication progress
--  [-34] -  Transaction in MasterCard installment choice progress
--  [-35] -  Transaction MasterCard installment auto cancelled
--  [-36] -  Transaction MasterCard installment user cancelled
--  [-37] -  Invalid recurring expiration date
--  [-38] -  UPI (China Union Pay) server error response
--  [-39] -  Transaction in confirmation progress
--  [-40] -  Transaction form in progress
----------------------------------------------------------------------
local rc_str = ctx:valget(2)    -- Result as string

local rc = -1                   -- Result code
if(rc_str) then rc = tonumber(ctx:valget(2)) end

local rc_text  = ctx:valget(3)  -- RC text
local terminal = ctx:valget(21) -- Terminal id

----------------------------------------------------------------------
-- Available transaction state values:
----------------------------------------------------------------------
--   [0]  -  Initial transaction state, undefined state as example: first request 
--   [1]  -  Transaction in progress state in TS(NS) side
--   [2]  -  Repeate transaction
--   [3]  -  Transaction success
--   [4]  -  Transaction not response from TS(NS) side
--   [5]  -  Transaction declined by authentication
--   [6]  -  Client side authentication in progress OTP verify code or random authorization amount
--   [7]  -  Client is authenticated by OTP verify code or random authorization amount
--   [8]  -  Transaction in authentication check state
--   [9]  -  Client side MasterCard installments in progress
--   [10] -  Process MasterCard installments auto or requested from user choice
--   [11] -  Client side UPI (China Union Pay) authentication in progress
--   [12] -  Client side confirmation (DCC) in progress
--   [13] -  Client side confirmation (DCC) was cancelled
--   [14] -  Client side transaction form in progress
--   [15] -  Client side 3D-Secure authentication in progress
----------------------------------------------------------------------
local tr_state    = ctx:valget(128) -- Transaction state

local order_id    = ctx:valget(27)  -- Order id
local trans_desc  = ctx:valget(58)  -- Transaction description
local cur_name    = ctx:valget(26)  -- Currency name
local tran_amount = ctx:valget(8)   -- Transaction amount
local amount      = ctx:valget(25)  -- Original merchant transaction amount
local pan         = ctx:valget(12)  -- PAN

local approval_id = ctx:valget(4)   -- Authorization id
local rrn         = ctx:valget(28)  -- RRN
local acq_fee     = ctx:valget(157) -- Commission
local int_ref     = ctx:valget(51)  -- Internal reference

local rev_amnt_chain = ctx:valget(237) -- Partial reversal amount chain
local tr_type        = ctx:valget(212) -- Original transaction type
-- Original transaction timestamp
local tran_time_stamp = ctx:valget(47)

-- Redefine response code & action code
if (tr_state) then
	if tr_state == '14' then     -- Client side transaction form in progress
		action_code = '3'
		rc_str = '40'
		ctx:valset(1,action_code)
		ctx:valset(2,rc_str)
		rc_text = 'Client side transaction form in progress'
	elseif tr_state == '15' then -- Transaction in 3D authentication
		action_code = '3'
		rc_str = '33'
		ctx:valset(1,action_code)
		ctx:valset(2,rc_str)
		rc_text = 'Client 3D-Secure authentication in progress'
	elseif tr_state == '2' then
		action_code = '3'
		rc_str = '31'
		ctx:valset(1,action_code)
		ctx:valset(2,rc_str)
	elseif tr_state == '6' then  -- Client authentication in progress
		rc_text = 'Client authentication in progress'
		if (action_code) then
			if action_code == '10' then
				rc_text = 'Client verify by OTP authentication code in progress'
			elseif action_code == '11' then
				rc_text = 'Client verify by random amount in progress'
			end
		end
		action_code = '3'
		rc_str = '33'
		ctx:valset(1,action_code)
		ctx:valset(2,rc_str)
	elseif tr_state == '12' then -- Client side confirmation (DCC) form in progress
		action_code='3' 
		ctx:valset(1,action_code)
		rc_str='39' 
		ctx:valset(2,rc_str)
	elseif tr_state == '13' then -- Client side confirmation (DCC) was cancelled
		action_code='3' 
		ctx:valset(1,action_code)
		rc_str='25' 
		ctx:valset(2,rc_str)
		rc_text='Transaction confirmation state was canceled by user'
		ctx:valset(3,rc_text)
	elseif tr_state == '1' then  -- Transaction in progress state in TS(NS) side
		action_code = '3'
		rc_str = '31'
		ctx:valset(1,action_code)
		ctx:valset(2,rc_str)
	elseif tr_state == '4' then -- Transaction not response from TS(NS) side
		action_code='3'
		ctx:valset(1,action_code)
		rc_str='-3'
		ctx:valset(2,rc_str)
	elseif tr_state == '5' then -- Transaction declined by authentication
		action_code='3'
		ctx:valset(1,action_code)
		rc_str='-19'
		ctx:valset(2,rc_str)
		if (tran_amount) and tonumber(tran_amount) == 0 then tran_amount = amount end
	end
end

-- Calculate signature
ext:egwsign()

-- Get transaction signature
local p_sign     = ctx:valget(44)  -- Transaction sign data
local nonce      = ctx:valget(61)  -- Nonce
local time_stamp = ctx:valget(47)  -- Timestamp

-- Set response headers
local body = 'Pragma: no-cache'..eos
body = body..'Cache-Control: no-store'..eos
body = body..'Content-type: text/html; charset=UTF-8'..eos
body = body..'Strict-Transport-Security: max-age=31536000; includeSubDomains'..eos..eos

-- Set response HTML body
body = body..'<center><font size=4><p>Check status transaction</p><p>This is the transaction summary information</p><table border=1 cellpadding=5>'
if(action_code) then body = body..'<tr><td>Action code:</td><td> '..action_code..' </td></tr>' end
if(rc_str) then body = body..'<tr><td>Response code:</td><td> '..rc_str..' </td></tr>' end
if(rc_text) then body = body..'<tr><td>Transaction status message:</td><td> '..rc_text..' </td></tr>' end
body = body..'<tr><td>Terminal:</td><td> '..terminal..' </td></tr>'
if(pan) then body = body..'<tr><td>Card number:</td><td> '..pan..' </td></tr>' end
if(amount and rc ~= -24 ) then body = body..'<tr><td>Transaction amount:</td><td> '..amount..' </td></tr>' end
if(cur_name and rc ~= -24 ) then body = body..'<tr><td>Transaction currency:</td><td> '..cur_name..' </td></tr>' end
if(tran_date) then body = body..'<tr><td>Transaction date:</td><td> '..tran_date..' </td></tr>' end
if(tr_state) then body = body..'<tr><td>Transaction state:</td><td> '..tr_state..' </td></tr>' end
body = body..'<tr><td>Merchant order id:</td><td> '..order_id..' </td></tr>'

if( rc == 0 ) then
	if(acq_fee) then body = body..'<tr><td>Acquirer\'s fee:</td><td> '..acq_fee..' </td></tr>' end
	if(approval_id) then body = body..'<tr><td>Your bank\'s approval code:</td><td> '..approval_id..' </td></tr>' end
	if(rrn) then body = body..'<tr><td>Transaction reference with the merchant\'s bank:</td><td> '..rrn..' </td></tr>' end
	if(int_ref) then body = body..'<tr><td>Internal transaction reference:</td><td> '..int_ref..' </td></tr>' end
	local merch_token_id = ctx:fget(227); -- Merchant token id
	if(merch_token_id) then
		body = body..'<tr><td>Merchant token with the merchant\'s bank:</td><td> '..merch_token_id..' </td></tr>'
	end
end

if(rev_amnt_chain) then
		for rev_amnt in string.gmatch(rev_amnt_chain, '([^,]+)') do
		body = body..'<tr><td>Partial reversal amount:</td><td> '..rev_amnt..' </td></tr>'
	end
end
if(tr_type) then body = body..'<tr><td>Original transaction type:</td><td> '..tr_type..' </td></tr>' end
if(time_stamp) then body = body..'<tr><td>Timestamp:</td><td> '..time_stamp..' </td></tr>' end
if(nonce) then body = body..'<tr><td>Nonce:</td><td> '..nonce..' </td></tr>' end
if(p_sign) then body = body..'<tr><td>Transaction signature:</td><td> '..p_sign..' </td></tr>' end
body = body..'</table><p>Thank you for using our services.</p></font><p>&nbsp;</p><center><a href="/card.html">Return to home page</a></center>'

return body

 
