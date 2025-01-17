## System Layout Service \(SLS\)

The System Layout Service \(SLS\) holds information about the system design, such as the physical locations of network hardware, compute nodes, and cabinets. It also stores information about the network, such as which port on which switch should be connected to each compute node.

SLS stores a generalized abstraction of the system that other services can access. The Hardware State Manager \(HSM\) keeps track of information for hardware state or identifiers. SLS does not need to change as hardware within the system is replaced.

Interaction with SLS is required if the system setup changes. For example, if system cabling is altered, or if the system is expanded or reduced. SLS does not interact with the hardware. Interaction with SLS should occur only during system installation, expansion, and contraction.

SLS is responsible for the following:

-   Providing an HTTP API to access site information
-   Storing a list of all hardware
-   Storing a list of all network links
-   Storing a list of all power links

### Table of Contents

* [Dump SLS Information](Dump_SLS_Information.md)
* [Load SLS Database with Dump File](Load_SLS_Database_with_Dump_File.md)
* [Add UAN CAN IP Addresses to SLS](Add_UAN_CAN_IP_Addresses_to_SLS.md)
* [Update SLS with UAN Aliases](Update_SLS_with_UAN_Aliases.md)
* [Create a Backup of the SLS Postgres Database](Create_a_Backup_of_the_SLS_Postgres_Database.md)
* [Restore SLS Postgres Database from Backup](Restore_SLS_Postgres_Database_from_Backup.md)
* [Restore SLS Postgres without an Existing Backup](Restore_SLS_Postgres_without_an_Existing_Backup.md)