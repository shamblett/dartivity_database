# dartivity_database

This package provides the database component of the [Dartivity](https://github.com/shamblett/dartivity) suite
of IOT monitoring and control packages.

The database component consists of both Dartivity resource definition classes and
the database classes which use them. This allows the database classes to be
specialised for any particular usage such as the resource database class which provides
general database facilities for the Dartivity resource class.

Underlying the database classes are database driver classes that perform the
function of interfacing with a specific database. Currently only one database driver
is supported, for CouchDb. CouchDb gives an efficient, scalable NoSql database
solution that supports full redundancy and replication facilities. This allows
historic data such as events etc. to be handled seperately from current live data giving
better access to such data.

This structure allows different database architectures to be
used should future requirements call for this, for example Googles Cloud Datastore or
even a traditional SQL database such as MariaDb.

The database component can be used anywhere in the Dartivity suite, by Dartivity clients for
discovered resource handling and event handling and by the [Dartivity Control](https://github.com/shamblett/dartivity_control)
front end web application for access to resource parameters, events etc.

Note that in this release only resource handling is supported, please refer to the individual
class descriptions for more specific details and the test suite for usage examples.


