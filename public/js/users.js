$(document).ready(function(){

function addRemoveClass(theRows){

	theRows.removeClass("odd even");
    theRows.filter(":odd").addClass("odd");
    theRows.filter(":even").addClass("even");
}

var rows = $("table#table-usuarios tr:not(:first-child)");

addRemoveClass(rows);

$("#selectC").on("change", function() {

	var selected = this.value;

	if(selected != "Todos") {

		rows.filter("[position=" + selected + "]").show();
		rows.not("[position=" + selected + "]").hide();
		var visibleRows= rows.filter("[position=" + selected + "]");

		addRemoveClass(visibleRows);
	} else {
		rows.show();
		addRemoveClass(rows);
	}
  });	
});