/**
* Proxy event dispatcher used by SmartContract instances.
*
* (C)opyright 2014 to 2017
*
* This source code is protected by copyright and distributed under license.
* Please see the root LICENSE file for terms and conditions.
*
*/

package org.cg {
	
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import org.cg.SmartContract;
	
	public class SmartContractEventDispatcher extends EventDispatcher {
		
		private var _contract:SmartContract = null; //dispatching SmartContract
		
		/**
		 * Creates a new instance.
		 * 
		 * @param	sourceContract The source or dispatching contract instance to assign to the class' 'contract' property.
		 */
		public function SmartContractEventDispatcher(sourceContract:SmartContract) {
			this._contract = sourceContract;
			super(null);
		}
		
		/**
		 * A reference to the dispatching SmartContract instance.
		 */
		public function get contract():SmartContract {
			return (this._contract);
		}		
	}
}