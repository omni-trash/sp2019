// Save in Site Assets as JSLink_FieldValuesFromUrl.js and set in the New Form WebPart the JSLink (under Miscellaneous) to that file
(function () {
    SP.SOD.executeOrDelayUntilScriptLoaded(function() {
		var overrides = {
            Templates: {
                Fields: {
                    // Custom "Von" Field is Date and Time
                    Von: {
                        NewForm: function(ctx) {
                            // Take Value from URL and Render Field Input Form
                            ctx.CurrentFieldValue = GetUrlKeyValue('Von');
                            return SPFieldDateTime_Edit(ctx);
                        }
                    }
                }
            }
        };

        SPClientTemplates.TemplateManager.RegisterTemplateOverrides(overrides);
	}, "clienttemplates.js");
})();
