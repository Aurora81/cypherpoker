/**
* Developer debugging and logging class. 
*
* (C)opyright 2014 to 2017
*
* This source code is protected by copyright and distributed under license.
* Please see the root LICENSE file for terms and conditions.
*
*/

package org.cg {	
	
	import flash.display.MovieClip;
	import starling.core.Starling;
	import flash.events.ContextMenuEvent;
	import flash.events.Event;
	//import flash.events.KeyboardEvent;
	import starling.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.ContextMenu;
	import flash.ui.ContextMenuItem;
	import flash.ui.ContextMenuBuiltInItems;
	import flash.ui.ContextMenuClipboardItems;
	import flash.ui.Keyboard;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.desktop.ClipboardTransferMode;
	import flash.utils.getTimer;
	import org.cg.interfaces.IView;
	import com.bit101.components.TextArea;
	import com.bit101.components.PushButton;
	
	public class DebugView extends MovieClip implements IView {
			
		private static var _debugLog:Vector.<String> = new Vector.<String>(); //debug messages added in order
		private var _currentDebugPosition:int = 0; //current line in _debugLog
		private static var _instances:Vector.<DebugView> = new Vector.<DebugView>();
		private var _contextMenu:ContextMenu = null; //right-click context menu
		private var _toggleContextAction:ContextMenuItem = null; //switches to debugview
		private var _copyContextAction:ContextMenuItem = null; //copies log to clipboard
		private var _clearContextAction:ContextMenuItem = null; //clears log
		//UI elements
		protected var debugText:TextArea;
		protected var clearDebugBtn:PushButton;
		protected var copyDebugBtn:PushButton;
		protected var toggleDebugBtn:PushButton;
		
		/**
		 * Creates a new instance. Add the instance to the display list to initialize.
		 */
		public function DebugView() {
			_instances.push(this);
			addEventListener(Event.ADDED_TO_STAGE, initialize);
			addEventListener(Event.REMOVED_FROM_STAGE, destroy);
			super();			
		}
			
		/**
		 * Returns an instance number for a specified DebugView instance.
		 * 
		 * @param	instanceRef A reference to the DebugView instance for which to find an instance number for.
		 * 
		 * @return The instance number of the specified EthereumConsoleVew instance.
		 */
		public static function instanceNum(instanceRef:DebugView):int {
			for (var count:int = 0; count < _instances.length; count++) {
				if (_instances[count] == instanceRef) {
					return (count);
				}
			}
			return ( -1);
		}
		
		/**
		 * Returns a specific DebugView instance.
		 * 
		 * @param	instanceNum the instance number of the DebugView instance to return.
		 * 
		 * @return The EthereumConsoleView instance specified.
		 */
		public static function instance(instanceNum:int):DebugView {			
			return (_instances[instanceNum]);
		}
		
		/**
		 * Add text to the debug log and output stream.
		 * 
		 * @param	textStr An ActionScript object to trace to
		 * the debug log and output stream, like the trace() parameter.
		 */
		public static function addText(textStr:*):void {			
			textStr = getTimer() + ": "+ textStr;
			_debugLog.push(String(textStr) + "\n");	
			trace (textStr);
			try {
				for (var count:int = 0; count < _instances.length; count++) {
					_instances[count].updateDebugText();
				}
			} catch (err:*) {
			}
		}
		
		/**
		 * Resets all DebugView instances by clearing the log and log displays.
		 */
		public static function reset():void {
			_debugLog = new Vector.<String>();
			for (var count:uint = 0; count < _instances.length; count++) {
				_instances[count].resetDebugText();
			}	
		}
		
		/**
		 * Clears the displays of all of the DebugView instances, but does not
		 * clear the log.
		 * 
		 * @param	updateAfterClear If true, the DebugView instances will be
		 * updated with any new log messages added since the last update.
		 */
		public static function clear(updateAfterClear:Boolean = false):void {
			for (var count:uint = 0; count < _instances.length; count++) {
				_instances[count].clearDebugText(updateAfterClear);
			}
		}
		
		/**
		 * Initializes the view. Implements IView interface.
		 */
		public function initView():void {			
			debugText = new TextArea(this);
			debugText.width = stage.stageWidth;
			debugText.height = stage.stageHeight-30;			
			debugText.selectable = true;
			debugText.editable = false;
			clearDebugBtn = new PushButton(this, 0, stage.stageHeight-25, "CLEAR", onClearClick);
			copyDebugBtn = new PushButton(this, 110, stage.stageHeight-25, "COPY TO CLIPBOARD", onCopyClick);
			toggleDebugBtn = new PushButton(this, 220, stage.stageHeight-25, "TOGGLE DEBUG LOG", onToggleClick);
		}
		
		/**
		 * Toggles UI visibility.
		 */
		public function toggleViewVisibility():void {
			if (visible == false) {
				//about to show view...				
				parent.setChildIndex(this, parent.numChildren - 1);
				visible = true;
				updateDebugText();
			} else {
				visible = false;
			}			
		}
		
		/**
		 * Destroys the DebugView and removes it from its parent display list.
		 * 
		 * @param	... args
		 */
		public function destroy(... args):void 	{
			removeEventListener(Event.REMOVED_FROM_STAGE, destroy);
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);
			var compInstances:Vector.<DebugView> = new Vector.<DebugView>();
			for (var count:uint = 0; count < _instances.length; count++) {
				var currentInstance:DebugView = _instances[count];
				if (currentInstance != this) {
					compInstances.push(currentInstance);
				}
			}
			_instances = compInstances;
		}
		
		/**
		 * Resets the debug log position. Does not clear the contents.
		 */
		protected function resetDebugText():void {
			clearDebugText(true);
		}
		
		/**
		 * Clears the contents of the debug log and resets its position.
		 * 
		 * @param	updateAfterClear If true, an update is invoked in the debugging UI after
		 * the reset.
		 */
		protected function clearDebugText(updateAfterClear:Boolean = false):void {
			_debugLog = new Vector.<String>();
			resetDebugText();
			if (updateAfterClear) {
				updateDebugText();
			}
		}
		
		/**
		 * Updates the debugging UI.
		 */
		protected function updateDebugText():void {
			if (_currentDebugPosition > _debugLog.length) {
				_currentDebugPosition = 0;	
			}
			for (var count:int = _currentDebugPosition; count < _debugLog.length; count++) {
				try {
					debugText.text += _debugLog[count];
					_currentDebugPosition++;
				} catch (err:*) {					
				}
			}
		}
		
		/**
		 * Copies the debugging log to the OS clipboard.
		 */
		protected function copyLogToClipboard():void {
			var dataStr:String = new String();
			for (var count:int = 0; count < _debugLog.length; count++) {
				dataStr += _debugLog[count] + "\n";
			}
			Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, dataStr, true);
		}
		
		/**
		 * Handles "copy to clipboard" functionality via mouse click.
		 * 
		 * @param	eventObj A MouseEvent object.
		 */
		protected function onCopyClick(eventObj:MouseEvent):void {
			copyLogToClipboard();
		}
		
		/**
		 * Handles "clear clipboard" functionality via mouse click.
		 * 
		 * @param	eventObj A MouseEvent object.
		 */
		protected function onClearClick(eventObj:MouseEvent):void {
			debugText.text = "";
		}
		
		/**
		 * Handles "toggle log" functionality via mouse click.
		 * 
		 * @param	eventObj A MouseEvent object.
		 */
		protected function onToggleClick(eventObj:MouseEvent):void {
			toggleViewVisibility();
		}
		
		/**
		 * Handles player context menu selections.
		 * 
		 * @param	eventObj A ContextMenuEvent object.
		 */
		protected function onContextMenuSelect(eventObj:ContextMenuEvent):void {			
			var contextMenuItem:ContextMenuItem = eventObj.target as ContextMenuItem;
			if (contextMenuItem == _toggleContextAction) {
				toggleViewVisibility();
			}
			if (contextMenuItem == _copyContextAction) {
				onCopyClick(null);
			}
			if (contextMenuItem == _clearContextAction) {
				clear(true);
			}
		}
		
		/**
		 * Handles key press events.
		 * 
		 * @param	eventObj A KeyBoardEvent object.
		 */
		protected function onKeyPress(eventObj:KeyboardEvent):void {
			if (eventObj.altKey) {
				if ((eventObj.keyCode == 68) || (eventObj.keyCode == 16)) {
					if (this.visible) {
						DebugView.addText ("Hiding DebugView by hot-key.");
						this.visible = false;
					} else {
						DebugView.addText ("Showing DebugView by hot-key.");
						this.visible = true;
					}
				}
			}
		}
		
		/**
		 * Initializes tne DebugView instance and adds context menu options.
		 * 
		 * @param	eventObj An Event object.
		 */
		protected function initialize(eventObj:Event):void {			
			removeEventListener(Event.ADDED_TO_STAGE, initialize);
			/*
			//standard Flash/AIR context menu, doesn't work with Starling
			if (parent.contextMenu == null) {
				var _contextMenu:ContextMenu = new ContextMenu();						
			} else {
				_contextMenu = parent.contextMenu as ContextMenu;
			}
			_toggleContextAction = new ContextMenuItem("DEBUG » Toggle log");
			_toggleContextAction.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuSelect);
			_copyContextAction = new ContextMenuItem("DEBUG » Copy log to clipboard");
			_copyContextAction.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuSelect);								
			_clearContextAction = new ContextMenuItem("DEBUG » Clear log");
			_clearContextAction.addEventListener(ContextMenuEvent.MENU_ITEM_SELECT, onContextMenuSelect);
			_contextMenu.customItems.push(_toggleContextAction);
			_contextMenu.customItems.push(_copyContextAction);
			_contextMenu.customItems.push(_clearContextAction);
			_contextMenu.hideBuiltInItems();
			try {
				parent.contextMenu = _contextMenu;
			} catch (err:*) {					
			}
			stage.addEventListener(KeyboardEvent.KEY_DOWN, onKeyPress);		
			*/
			StarlingContainer.instance.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.onKeyPress);
			visible = false;
		}		
	}
}