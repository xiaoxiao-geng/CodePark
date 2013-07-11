
local function getVaribleReg( varible )
	return string.format( "${%s}", varible )
end

cTemplate = class()

function cTemplate:init( templateText )
	self.templateText = templateText
	self.values = {}
end

function cTemplate:fSet( varible, value )
	self.values[ varible ] = value
end

function cTemplate:fEvaluate()
	local result = self.templateText
	for k, v in pairs( self.values ) do
		result = string.gsub( result, getVaribleReg( k ), v )
	end

	if string.find( result, "\$\{.+\}" ) then
		error( "has some no value varible!\n" .. debug.traceback() )
		return
	end

	return result
end








if UNIT_TEST then

	local caseHello = cTestcase()

	function caseHello:setup()
		self.template = cTemplate( "Hello, ${name}" )
	end

	function caseHello:assert_eva( expected )
		assert_equal( expected, self.template:fEvaluate() )
	end

	function caseHello:test_evaluate_hello()
		self.template:fSet( "name", "Reader" )
		self:assert_eva( "Hello, Reader")

		self.template:fSet( "name", "Jack" )
		self:assert_eva( "Hello, Jack")
	end

	function caseHello:test_other_varible()
		assert_error( "", cTemplate.fEvaluate, self.template )

		self.template:fSet( "name", "Reader" )
		self.template:fSet( "other_varible", "some value" )
		self:assert_eva( "Hello, Reader" )
	end

	function caseHello:test_error()
		assert_error( "", cTemplate.fEvaluate, self.template )
	end



	local caseMutal = cTestcase()

	function caseMutal:setup()
		self.template = cTemplate( "This is ${name}'s ${object}")
	end

	function caseMutal:assert_eva( expected )
		assert_equal( expected, self.template:fEvaluate() )
	end

	function caseMutal:test_evaluate_mutal_value()
		self.template:fSet( "name", "Jack" )
		self.template:fSet( "object", "car" )
		self:assert_eva( "This is Jack's car" )
	end

end