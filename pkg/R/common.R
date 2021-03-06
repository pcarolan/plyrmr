# Copyright 2013 Revolution Analytics
#    
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#      http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, 
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#strings
# of perl fame
qw = function(...) as.character(match.call())[-1]

#functional
constant = 
	function(x)
		function(...) x

#curried arguments are eager, the rest lazy
CurryHalfLazy = 
	function(FUN, ...) {
		.orig = list(...)
		function(...) 
			do.call(FUN, c(.orig, dots(...)))}

# retun a function whose env is a copy of the original env (one level only)
freeze.env = 
	function(x) {
		envx = environment(x)
		if(!is.null(envx)) {
			nenv = as.environment(as.list(envx))
			parent.env(nenv) = parent.env(envx)
			environment(x) = nenv}
		x}

#data frames

selective.I = function(x) if(is.list(x) && !is.data.frame(x)) I(x) else x

safe.cbind  = 
	function(...) {
		ll = lapply(list(...), selective.I)
		x = do.call(cbind, strip.nulls(ll))
		x[, unique(names(x)), drop = FALSE]}

data.frame = 
	function(..., row.names = NULL, check.rows = FALSE,
						check.names = TRUE, stringsAsFactors = default.stringsAsFactors()) {
		base::data.frame(
			lapply(
				list(...), 
				selective.I),
			row.names = row.names,
			check.rows = check.rows,
			check.names = check.names,
			stringsAsFactors = stringsAsFactors)}

as.data.frame.data.frame = splat(data.frame)

data.frame.fill = 
	function(..., filler = NA) {
		argl = list(...)
		argl = splat(c)(argl)
		maxlen = max(sapply(argl, length))
		sapply(
			seq_along(argl), 
			function(i) length(argl[[i]]) <<- maxlen)
		splat(data.frame)(argl)}
						
#lists

strip.nulls = 
	function(x) 
		x[!sapply(x, is.null)]

strip.null.args = 
	function(...)
		strip.nulls(list(...))

#dynamic scoping

non.standard.eval = 
	function(.data,  ..., .named = TRUE,  .envir = stop("Why wasn't .envir specified? Why?")) {
		force(.envir)
		dotlist = {
			if(.named)
				named_dots(...)
			else
				dots(...) }
		env = list2env(.data, parent = .envir)
		lapply(dotlist, function(x) eval(eval(x, env), env))}
