
var sketcherLoaded=false
var twIndex=0;

/*
 * Opening a new window for the help
 */
function help()
{
    var w = window.open("queryhelp.html",
	    "queryhelp"+(twIndex++).toString(),
	    "resizable=yes,width=470,height=270,scrollbars=yes,menubar=yes");
    w.focus();
}


function renameParams() {
    form = document.queryForm;
    for(i=0; i<4; i++) {
        var fieldObj = form["field"+i];
    	var field = fieldObj.options[fieldObj.selectedIndex].value;
	form["value"+i].name = field;
    }
}

/*
 * Checking if the data in the form is proper
 */
function checkForm(form) 
{
    form = document.queryForm;
    for(i=0; i<4; i++) {
    	var fieldObj = form["field"+i];
    	var field = fieldObj.options[fieldObj.selectedIndex].value;
	var value = form["value"+i].value;
    	if(field == "cd_molweight"
	        && value != null && value != "") {
	    if(isNaN(parseFloat(value))) {
	    	alert("'" + value + "' is not a valid floating point value");
	    	return false;
	    } else {
	    	form["value"+i].value = parseFloat(value);
	    }
	} else if((field == "cd_id" || field == "stock") 
	        && value != null && value != "") {
	    if(isNaN(parseInt(value))) {
	    	alert("'" + value + "' is not a valid integer value");
	    	return false;
            } else {
	    	form["value"+i].value = parseInt(value);
	    }
	}
    }
    return true;
}

/*
 * Submit form only if the frames have been loaded
 */
function submitIfLoaded(whatToDo)
{
//    if(sketcherLoaded) {
        form = document.queryForm;
//	form.action = "index.jsp" + location.search;
	form.molfile.value = document.msketch.getMol('mol');
//  	renameParams();
	//if(checkForm(form))
	    form.submit();
//    } else
//	alert("Page loading. Please wait.");
}

/*
 * Functions for the buttons
 */
function swapImgRestore() {
  if (document.swapImgData != null)
    for (var i=0; i<(document.swapImgData.length-1); i+=2)
      document.swapImgData[i].src = document.swapImgData[i+1];
}

function preloadImages() { 
  if (document.images) {
    var imgFiles = preloadImages.arguments;
    if (document.preloadArray==null) document.preloadArray = new Array();
    var i = document.preloadArray.length;
    with (document) for (var j=0; j<imgFiles.length; j++) {
      preloadArray[i] = new Image;
      preloadArray[i++].src = imgFiles[j];
  } }
}

function swapImage() {
  var i,j=0,objStr,obj,swapArray=new Array,oldArray=document.swapImgData;
  for (i=0; i < (swapImage.arguments.length-2); i+=2) {
    objStr = swapImage.arguments[(navigator.appName == 'Netscape')?i:i+1];
    if ((objStr.indexOf('document.layers[')==0 && document.layers==null) ||
        (objStr.indexOf('document.all[')   ==0 && document.all   ==null))
      objStr = 'document'+objStr.substring(objStr.lastIndexOf('.'),objStr.length);
    obj = eval(objStr);
    if (obj != null) {
      swapArray[j++] = obj;
      swapArray[j++] = (oldArray==null || oldArray[j-1]!=obj)?obj.src:oldArray[j];
      obj.src = swapImage.arguments[i+2];
  } }
  document.swapImgData = swapArray; //used for restore
}


function writeConditions() {
    for(i=0; i<4; i++) {
            document.writeln(
                "<tr>\n"+
                "<td>\n"+
                "<select name='field"+i+"'>\n"+
                "<option value='cd_id'>Id\n"+
                "<option value='cd_formula'"+(i==0? " selected":"")+">Formula\n"+
                "<option value='cd_molweight'"+(i==1? " selected":"")+">Molweight\n"+
                "<option value='name'>Name\n"+
                "<option value='stock'"+(i==2? " selected":"")+">Stock (mg)\n"+
                "</select>\n"+
                "</td>\n"+
                "<td>\n"+
                "<select name='relation"+i+"'>\n"+
                "<option value='<'>&lt;\n"+
                "<option value='<='>&lt;=\n"+
                "<option value='=' selected>=\n"+
                "<option value='>='>&gt;=\n"+
                "<option value='>'>&gt;\n"+
                "</select>\n"+
                "</td>\n"+
                "<td>\n"+
                "<input type='text' name='value"+i+"' size=15>\n"+
                "</td>\n"+
                "</tr>\n"
		);
        }
}
