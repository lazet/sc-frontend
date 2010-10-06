package util
{
	import mx.validators.ValidationResult;
	import mx.validators.Validator;
	
	import spark.components.TextInput;
	
	public class PasswordConsistenceValidate extends Validator
	{
		public var password1:TextInput;
		public var inconsistenceError:String;
		public function PasswordConsistenceValidate()
		{
			super();
		}
		override protected function doValidation(value:Object):Array{
			var results:Array = super.doValidation(value);
			if(this.source[this.property] != password1.text){
				results.push(new ValidationResult(
					true, null, "inconsistenceError",
					inconsistenceError));
				return results;
			}
			else{
				return results;
			}
		}
	}
}