package operate.modules.consume
{
	import mx.validators.ValidationResult;
	import mx.validators.Validator;

	public class MixConsistantValidator extends Validator
	{
		public function MixConsistantValidator()
		{
			super();
		}
		public var partner:Object;
		public var partnerProperty:String;
		
		public var inconsistantError:String;
		
		override protected function doValidation(value:Object):Array{
			var results:Array = super.doValidation(value);
			if((this.source[this.property] != "" && partner[partnerProperty] == "") ||
			   (this.source[this.property] == "" && partner[partnerProperty] != "")){
				results.push(new ValidationResult(
					true, null, "inconsistantError",
					inconsistantError));
				return results;
			}
			else{
				return results;
			}
		}
	}
}