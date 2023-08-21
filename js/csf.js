// Global object for CSF data and functions
csf = {
	onLoad: function() {
		if (csf.pageCategory) {
			console.log("Found page category");
			activeLink = document.getElementById("navbar_" + csf.pageCategory);
			if (activeLink) {
				console.log("Found active link");
				activeLink.classList.add("active");
			}
		}
	}
}

// vim:ts=2:
