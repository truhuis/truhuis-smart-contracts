// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

error MUNICIPALITY_NOT_REGISTERED();
error INVALID_PERSON_RESIDENCY(bytes4 actual, bytes4 required);

enum CivilStatus {
    UNMARRIED,
    MARRIED,
    REGISTERED_PARTNERSHIP,
    DIVORCED,
    WIDOW,
    WIDOWER
}

enum Gender {
    FEMALE,
    MALE,
    UNKNOWN
}

enum Residency {
    DUTCH_NATIONALITY,
    PRIVILEGE,
    RESIDENCE_PERMIT,
    PENDING_CONSIDERATION_OF_THE_APPLICATION_FOR_A_RESIDENCE_PERMIT,
    NONE
}

struct Name {
    bytes32 first;
    bytes32 last;
}

struct DateOfBirth {
    uint24 day;
    uint24 month;
    uint24 year;
}

struct PlaceOfBirth {
    bytes32 city;
    bytes32 province;
    bytes3 country;
}

struct Parents {
    address father;
    address mother;
}

struct Children {
    bool hasChildren;
    address[] childrenAccounts;
}

struct CurrentAddress {
    bytes32 street;
    uint8 houseNumber;
    bytes7 postcode;
    bytes4 municipality; // CBS-code
}

struct PersonalRecords {
    Name name;
    Gender gender;
    address account;
    DateOfBirth dateOfBirth;
    PlaceOfBirth placeOfBirth;
    Parents parents;
    CivilStatus civilState;
    Children children;
    Residency residency;
    CurrentAddress currentAddress;
}

interface IPersonalRecordsDatabase {
    function isDutchNationality(address _person) external view returns (bool);
}
