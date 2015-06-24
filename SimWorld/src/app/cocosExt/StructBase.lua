local StructBase = class("StructBase")

--- 构造方法
-- @param fields 字段定义
function StructBase:ctor(fields)
	if fields then
		-- 使用fields初始化自身
		self:fillData(fields)
	end
end

--- 使用data中的字段填充自身
-- 如果data中对应的字段为nil，也会将自身设置为nil
-- @param fields作为模板的字段定义集
function StructBase:fillFields(data, fields)
	for k, v in pairs(fields) do
		self[k] = clone(data[k])
	end
end

--- 使用data填充自身
-- 将data中所有字段拷贝到自身中
function StructBase:fillData(data)
	for k, v in pairs(data) do
		self[k] = v
	end
end

return StructBase