# Fossilize

Fossilize is an FFI-powered C-extension for Ruby that interfaces with the delta encoding algorithm
created by D. Richard Hipp for the [FOSSIL SCM project][fossil]. It enables a Ruby program to quickly (and I mean quickly) generate a delta between files and strings, as well as apply those deltas.

Deltas can be created between a Ruby File object and a String and vice-versa, so you can read in some JSON from a remote server as a String, create a delta from your local File copy and then apply that delta to your local copy to merge the differences.

**The project is currently considered a work-in-progress.**

[fossil]: http://www.fossil-scm.org

## Why use Fossilize?

The algorithm itself is based on rsync and is a form of [Delta Encoding][de] (sometimes called Delta Compression). A delta encoding algorithm is designed to analyse two pieces of data and produce a delta (the differences between them) as an encoded string.

Here, I'll give an example. If I give the following two strings to the algorithm:

    xiy needs to get a job!
    maybe xiy needs to get a real job!
    
It spits out the following *delta string* (I sense sarcasm in its tone):

    _
    6:maybe J@0,B:*real* job!1rx1Az;

Although explaining the format of the delta string is out of the scope of this internets page, you can see why this algorithm is so damn cool.

For more info on the algorithm, see the excellent documentation over [here][delta-format].

Git uses a similar algorithm to only store the changes to tracked files between revisions. However, the deltas created by Git can sometimes be huge.

### Real World Examples

As a real world example, here are the differences between `ruby/ruby/array.c@e3efce` and its previous commit (you can see the diff [here](https://github.com/ruby/ruby/commit/e3efce6df1aa691e17c59f442b35b4fd129d3a13#array.c)).

    WBD
    N86@0,g:rb_random_ulong_limited((randgen), (max)-1)U@OvG,8:shuffle!H@OGW,_B@N9S,4:long49@Nii,F:i = RAND_UPTO(lb@NnL,4:<= iK@Nn~,N@Ntk,H:	}
    	return ptr[i]b@3Rx,33@Npg,H:RAND_UPTO(len - iG@L00,8:k = len;~@NtF,C:len < k) {
    	R@O1i,K@DZ~,_:n; ++i) {
    		if (rnds[i] >= len) {
    		I@F9W,C:new2(0);
    		}H@QGF,U@NrC,16@Nu_,7:rnds[0]r@Nv~,L:rnds[0];
    	j = rnds[1]1F@Nxf,Z:rnds[0];
    	j = rnds[1];
    	k = rnds[2]40@N~E,I:rnds[0];
    	for (i=1J@OBW,B:k = rnds[i]86X@O4S,32IfMm;
    	
In terms of diffing, it wouldn't be hard to parse this delta and determine where in a file modifications took place at a *per-character level* as opposed to the traditional per-line approach.

### Things Fossilize is good at:

1. Patching - the only data to transmit is the delta string.
2. Diffing - although the format isn't human readable, it wouldn't be hard to make it so. Unlike *diff*, the algorithm compares by character, not by line.
3. Syncing - my project `wormhole` uses this algorithm to ensure it only syncs the updated portions of my files, not the entire thing.

### Things Fossilize is *not* good at:

1. Comparing differences between two almost completely different pieces of data (see [Wikipedia][de]).
2. Binary diffing - while it can successfully create and apply binary patches, there are algorithms and tools better designed for these types of files. `bsdiff` will create a 2kb diff whereas Fossilize will create a 4kb diff. This is probably due to the fact that the algorithm uses base64 encoding of plain-text which ends up with binary artefacts popping up in the diff. Although they don't make it into the output, it's obviously better to use something like bsdiff. It would, however, be possible to modify the algorithm to use a different "mode" for binary files that uses binary encoding instead.


[de]: http://en.wikipedia.org/wiki/Delta_encoding
[delta-format]: http://www.fossil-scm.org/xfer/doc/trunk/www/delta_format.wiki

## Installation

Add this line to your application's Gemfile:

    gem 'fossilize'

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install fossilize

## Licensing
Fossilized is distributed under the MIT License.

Fossil (and the Fossil delta encoding algorithm included within) are distributed under the Simplified BSD License/FreeBSD License:
    
    
    Copyright (c) 2006 D. Richard Hipp
    
    This program is free software; you can redistribute it and/or
    modify it under the terms of the Simplified BSD License (also
    known as the "2-Clause License" or "FreeBSD License".)
    
    This program is distributed in the hope that it will be useful,
    but without any warranty; without even the implied warranty of
    merchantability or fitness for a particular purpose.
    
    Author contact information:
       drh@hwaci.com
       http://www.hwaci.com/drh/

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
