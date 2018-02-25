alter session set container = cdb$root;
alter pluggable database otw close;
drop pluggable database otw including datafiles;
