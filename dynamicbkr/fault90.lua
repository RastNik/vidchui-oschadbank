#!/bin/lua

local eos = '\r\n'

local action_code = ctx:fget(1) -- Action code
local rc_str = ctx:fget(2)      -- Result as string
local rc_text = ctx:fget(3)     -- RC text
local terminal = ctx:fget(21)   -- Terminal id
local order_id = ctx:fget(27)   -- Order id
local tr_type = ctx:fget(212)   -- Original transaction type
local time_stamp = ctx:fget(47) -- Timestamp
local nonce = ctx:fget(61)      -- Nonce
local p_sign = ctx:fget(44)     -- Transaction sign data

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
body = body..'<tr><td>Merchant order id:</td><td> '..order_id..' </td></tr>'
if(tr_type) then body = body..'<tr><td>Original transaction type:</td><td> '..tr_type..' </td></tr>' end
if(time_stamp) then body = body..'<tr><td>Timestamp:</td><td> '..time_stamp..' </td></tr>' end
if(nonce) then body = body..'<tr><td>Nonce:</td><td> '..nonce..' </td></tr>' end
if(p_sign) then body = body..'<tr><td>Transaction signature:</td><td> '..p_sign..' </td></tr>' end
body = body..'</table><p>Thank you for using our services.</p></font><p>&nbsp;</p><center><a href="/card.html">Return to home page</a></center>'

return body

