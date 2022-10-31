<script type="text/javascript" src="http://code.jquery.com/jquery-3.5.0.min.js"></script>
<script type="text/javascript" defer>
// IIFE
(function() {
	// refresh page when dialog result is SP.UI.DialogResult.OK
	function refreshPage(dialogResult) {
		// we need a delay for our workflow to run
		// the workflow updates the title field
		//
		// if u dont have any workflows to run u can remove the timeout value
		setTimeout(function() {
			SP.UI.ModalDialog.RefreshPage(dialogResult);
		}, 500);
	}

	function calendarLoaded(calendar) {
		// lag of information, docs are useless
		// div.ms-acal-rootdiv
		var root = $(calendar["$1z_1"]);

		$("a[href*='DispForm.aspx']", root).each(function () {
			var $me = $(this);

			// we change from display to edit
			// comment out next line if u dont want to open the edit form
			$me.attr("href", $me.attr("href").replace("DispForm", "EditForm"));

			// remember
			var title = $me.text().replace(/[\r\n]/g, "");
			var url   = $me.attr("href");

			// remove
			$me.removeAttr("onclick");
			$me.removeAttr("target");

			$me.on("click", function(e) {
				e.preventDefault();

				var options = {
					title: "Kalender - " + title,
					autoSize:true,        
					url: url,
					dialogReturnValueCallback: refreshPage
				};

				SP.UI.ModalDialog.showModalDialog(options);
			});
		});
    };

	// https://www.codeproject.com/Tips/759006/Enhancing-SharePoint-Calendar-sp-ui-applicationpag
	SP.SOD.executeOrDelayUntilScriptLoaded(function() {
		// Week or Day Calendar View
		SP.UI.ApplicationPages.DetailCalendarView.prototype.renderGrids_Old = SP.UI.ApplicationPages.DetailCalendarView.prototype.renderGrids;
		SP.UI.ApplicationPages.DetailCalendarView.prototype.renderGrids = function renderGrids(param) {
			this.renderGrids_Old(param);
			calendarLoaded(this);
		};

		//Month Calendar View
		SP.UI.ApplicationPages.SummaryCalendarView.prototype.renderGrids_Old = SP.UI.ApplicationPages.SummaryCalendarView.prototype.renderGrids;
		SP.UI.ApplicationPages.SummaryCalendarView.prototype.renderGrids = function renderGrids(param) {
			this.renderGrids_Old(param);
			calendarLoaded(this);
		};

	}, "SP.UI.ApplicationPages.Calendar.js");
})();
</script>
