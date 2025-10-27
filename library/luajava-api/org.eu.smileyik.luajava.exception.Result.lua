---@meta
---@class org.eu.smileyik.luajava.exception.Result: java.lang.Object
---@field private SUCCESS org.eu.smileyik.luajava.exception.Result [STATIC] SUCCESS INSTANCE.
---@field private message string 
---@field private value any 
---@field private error any 
local Result = {}

---get the message.
---@public
---@return string 
function Result:getMessage() end

---just get value
---@public
---@return any the value, if this instance is error, then maybe return null.
function Result:getValue() end

---just get error
---@public
---@return any the error value, if this instance means success, then this must be null.
function Result:getError() end

---check this instance means error or not
---@public
---@return boolean true means error
function Result:isError() end

---success
---@public
---@return boolean true means success
function Result:isSuccess() end

---accept when result is success.
---@public
---@param consumer java.util.function.Consumer consumer
---@return org.eu.smileyik.luajava.exception.Result this result.
function Result:ifSuccessThen(consumer) end

---accept when result is failed.
---@public
---@param consumer java.util.function.Consumer consumer
---@return org.eu.smileyik.luajava.exception.Result this result.
function Result:ifFailureThen(consumer) end

---get the value if success, return other value if failed.
---@public
---@param other any the other value.
---@return any return value or other.
function Result:orElse(other) end

---get the value if success, return other value if failed.
---@public
---@param other java.util.function.Supplier the other value.
---@return any return value or other.
function Result:orElseGet(other) end

---if this is an error, then throws.
---@public
---@return nil 
function Result:justThrow() end

---if this is an error, then throws.
---@public
---@param clazz java.lang.Class target exception type
---@return nil 
function Result:justThrow(clazz) end

---if error then throw, else return the value.
---@public
---@return any the value
function Result:getOrThrow() end

---if error then throw, else return the value.
---@public
---@param clazz java.lang.Class the exception type.
---@return any the value
function Result:getOrThrow(clazz) end

---get value or sneaky throw exception
---@public
---@return any the value
function Result:getOrSneakyThrow() end

---just cast this result to target result.if you know it's work then you can use it.
---@public
---@return org.eu.smileyik.luajava.exception.Result the target result.
function Result:justCast() end

---@public
---@return org.eu.smileyik.luajava.exception.Result 
function Result:justCast(rtClass, reClass) end

---@private
---@return org.eu.smileyik.luajava.exception.Result 
function Result:justReplaceValue(newValue) end

---as same as mapValue method. but just replace value.
---@public
---@return org.eu.smileyik.luajava.exception.Result 
function Result:replaceValue(newValue) end

---transform value if success.
---@public
---@param f java.util.function.Function function
---@return org.eu.smileyik.luajava.exception.Result result
function Result:mapValue(f) end

---transform error if failed
---@public
---@param f java.util.function.Function function
---@return org.eu.smileyik.luajava.exception.Result result
function Result:mapError(f) end

---replace error to string. if error is throwable,then will just use Throwable.getMessage() and will not use param function.
---@public
---@param f java.util.function.Function covert function, will not call if error is Throwable.
---@return org.eu.smileyik.luajava.exception.Result 
function Result:replaceErrorString(f) end

---transform result
---@public
---@param rt java.util.function.Function transform result if success
---@param re java.util.function.Function transform error if failed
---@return org.eu.smileyik.luajava.exception.Result the result
function Result:map(rt, re) end

---@public
---@return org.eu.smileyik.luajava.exception.Result 
function Result:mapResultValue(function_) end

---@public
---@return org.eu.smileyik.luajava.exception.Result 
function Result:thenMap(function_) end

---@public
---@return org.eu.smileyik.luajava.exception.Result 
function Result:mapResult(function_) end

---if success then use value.toString else error.toStringif you want custom message please use map method;
---@public
---@return string 
function Result:toString() end

---@public
---@return org.eu.smileyik.luajava.exception.Result 
function Result:of(value, error) end

---@public
---@return org.eu.smileyik.luajava.exception.Result 
function Result:of(value, error, message) end

---@public
---@return org.eu.smileyik.luajava.exception.Result 
function Result:success() end

---@public
---@return org.eu.smileyik.luajava.exception.Result 
function Result:success(value) end

---@public
---@return org.eu.smileyik.luajava.exception.Result 
function Result:success(value, message) end

---@public
---@return org.eu.smileyik.luajava.exception.Result 
function Result:failure(error) end

---@public
---@return org.eu.smileyik.luajava.exception.Result 
function Result:failure(error, message) end

return Result