<script type="text/javascript">
		function loadMyAccount () {
			window.setTimeout(function () {
				var e = document.createElement("iframe");
				e.setAttribute("src", "https://mris--builddemo--c.cs9.visual.force.com/apex/myaccount");
				e.setAttribute("frameborder", 0);
				e.setAttribute("height", "100%");
				e.setAttribute("width", "100%");
				
				document.body.appendChild(e);
			}, 1000);
		}
		
		if (document.addEventListener) {
			document.addEventListener("DOMContentLoaded", function(){
				document.removeEventListener("DOMContentLoaded", arguments.callee, false);
				loadMyAccount();
			}, false );
		} 
		else if (document.attachEvent) {
			document.attachEvent("onreadystatechange", function(){
				if (document.readyState === "complete") {
					document.detachEvent("onreadystatechange", arguments.callee);
					loadMyAccount();
				}
			});

			if (document.documentElement.doScroll && window == window.top) 
				(function(){
					try {
						document.documentElement.doScroll("left");
					} catch(error) {
						setTimeout(arguments.callee, 0);
						return;
					}

					loadMyAccount();
				})();
		}
	</script>