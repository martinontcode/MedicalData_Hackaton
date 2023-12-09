// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Test Wallets on Sepolia
// DEPLOY
// 0x45eF361bC5C5f17D00e9e4F05758b83D3E36de6C
// PATIENT
// 0x95316Ec469Db7d7BeD5ad9AD5461a10a3614Eaac
// GENERAL DOCTOR (PEREARST)
// 0xc1CF1a1515654f7f3f300F977Fc786165F049001
// MEDICAL DOCTOR
// 0x1B405Bcc6742a4D1cF5291670fA1b6f3B665cE54
// VISION DOCTOR
// 0xAB033F00E9d53bd1a27D28Cc3F9D33cB489E46F9

/**
 * @title Health Data Management for Hackathon
 */
contract HealthData_Hackaton {

    // Define different structs used in the contract

    // struct patientBasicPersonalData
    // Includes: national_id, first_name, last_name, gender, date of birth, contact_phone
    struct patientBasicPersonalData {
        string hashedPatientBasicPersonalData;
    }

    // struct patientBasicMedicalData
    // Includes: height, weight, chronic_diseases, health_concerns
    struct patientBasicMedicalData {
        string hashedPatientBasicMedicalData;
    }

    // struct patientBasicVisionData
    // Includes: eye_color, eye_diseases_history, vision_metrics
    struct patientBasicVisionData {
        string hashedPatientBasicVisionData;
    }

    // struct patientPersonalDataList
    // List of general doctors assigned to a patient.
    // With ALL read/write access.
    struct patientAssignedGeneralDoctorList {
        address[] allowedDoctorList;
        mapping(address => bool) isAllowed;
    }

    // struct patientPersonalDataList
    // Access control list for personal data.
    struct patientPersonalDataAccessList {
        address[] allowedDoctorList;
        mapping(address => bool) isAllowed;
    }

    // struct patientMedicalDataList
    // Access control list for medical data.
    struct patientMedicalDataAccessList {
        address[] allowedDoctorList;
        mapping(address => bool) isAllowed;
    }

    // struct patientVisionDataList
    // Access control list for vision data.
    struct patientVisionDataAccessList {
        address[] allowedDoctorList;
        mapping(address => bool) isAllowed;
    }

    // Encoding variables

    // Patient data encode strings according to address and category
    mapping(address => string) private patientBasicPersonalDataEncodes;
    mapping(address => string) private patientBasicMedicalDataEncodes;
    mapping(address => string) private patientBasicVisionDataEncodes;

    // Patient doctor lists according to address
    mapping(address => patientAssignedGeneralDoctorList) private assignedGeneralDoctorList;
    mapping(address => patientPersonalDataAccessList) private personalDataAccessList;
    mapping(address => patientMedicalDataAccessList) private medicalDataAccessList;
    mapping(address => patientVisionDataAccessList) private visionDataAccessList;

    // Data encoding and updating functions

    // Handles updating and hashing Basic Personal Data
    // national_id, first_name, last_name, gender, date_of_birth, contact_phone
    function updateAndEncodePatientBasicPersonalData (
        address patientAddress,
        string memory national_id,
        string memory first_name,
        string memory last_name,
        string memory gender,
        string memory date_of_birth,
        string memory contact_phone
    ) private {

        // Access control checks
        require(msg.sender == patientAddress || personalDataAccessList[patientAddress].isAllowed[msg.sender]
        || assignedGeneralDoctorList[patientAddress].isAllowed[msg.sender]
        , "Caller is not authorized to update data");
    
        // Data combination and encoding
        string memory combinedData = string(abi.encodePacked(
            national_id, first_name, last_name, gender, date_of_birth, contact_phone
        ));

        // Encoding data to Base64 and storing
        string memory encodedData = encode(bytes(combinedData));
        patientBasicPersonalDataEncodes[patientAddress] = encodedData;

    }

    // Handles updating and hashing Basic Medical Data
    // height, weight, chronic_diseases, health_concerns
    function updateAndEncodePatientBasicMedicalData (
        address patientAddress,
        string memory height,
        string memory weight,
        string memory chronic_diseases,
        string memory health_concerns
    ) private {
        // Access control checks
        require(medicalDataAccessList[patientAddress].isAllowed[msg.sender]
        || assignedGeneralDoctorList[patientAddress].isAllowed[msg.sender]
        , "Caller is not authorized to update data");
    
        // Data combination and encoding
        string memory combinedData = string(abi.encodePacked(
            height, weight, chronic_diseases, health_concerns
        ));

        // Encoding data to Base64 and storing
        string memory encodedData = encode(bytes(combinedData));
        patientBasicMedicalDataEncodes[patientAddress] = encodedData;
    }

    // Handles updating and hashing Basic Vision Data
    // eye_color, eye_diseases_history, vision_metrics
    function updateAndEncodepatientBasicVisionData (
        address patientAddress,
        string memory eye_color,
        string memory eye_diseases_history,
        string memory vision_metrics
    ) private {
        // Access control checks
        require(visionDataAccessList[patientAddress].isAllowed[msg.sender]
        || assignedGeneralDoctorList[patientAddress].isAllowed[msg.sender]
        , "Caller is not authorized to update data");
    
        // Data combination and encoding
        string memory combinedData = string(abi.encodePacked(
            eye_color, eye_diseases_history, vision_metrics
        ));

        // Encoding data to Base64 and storing
        string memory encodedData = encode(bytes(combinedData));
        patientBasicVisionDataEncodes[patientAddress] = encodedData;
    }

    // Patient-specific functions

    // Allows patients to post their own basic personal data.
    /**
    * @dev patient_postOwnBasicPersonalData - Allow patients to post their own basic personal data.
    */
    function patientPostOwnBasicPersonalData (
        string memory national_id,
        string memory first_name,
        string memory last_name,
        string memory gender,
        string memory date_of_birth,
        string memory contact_phone,
        address generalDoctorAddress
    ) external {
        // Call the inherited function to update and encode the patient's personal data
        updateAndEncodePatientBasicPersonalData(
            msg.sender, // patientAddress is the sender of the transaction
            national_id,
            first_name,
            last_name,
            gender,
            date_of_birth,
            contact_phone
        );

        // Access control, add general doctor
        assignedGeneralDoctorList[msg.sender].allowedDoctorList.push(generalDoctorAddress);
        assignedGeneralDoctorList[msg.sender].isAllowed[generalDoctorAddress] = true;

    }

    // Allows patients to retrieve their own full data
    function patientGetOwnFullData() public view returns (string memory personalDataHash, string memory medicalDataHash, string memory visionDataHash) {
        
        address patientAddress = msg.sender; // sender of the transaction

        personalDataHash = patientBasicPersonalDataEncodes[patientAddress];
        medicalDataHash = patientBasicMedicalDataEncodes[patientAddress];
        visionDataHash = patientBasicVisionDataEncodes[patientAddress];

    }

    // Allows patients to set their full assigned doctors list
    function patientGetOwnDoctorAddress() public view returns (
            address[] memory generalDoctors, 
            address[] memory medicalDoctors, 
            address[] memory visionDoctors
        ) {
        generalDoctors = assignedGeneralDoctorList[msg.sender].allowedDoctorList;
        medicalDoctors = medicalDataAccessList[msg.sender].allowedDoctorList;
        visionDoctors = visionDataAccessList[msg.sender].allowedDoctorList;

    }

    // General doctor functions

    event DoctorDataAccessed(
        address indexed doctorAddress,
        address indexed patientAddress,
        string personalDataHash,
        string medicalDataHash,
        string visionDataHash
    );

    function generalDoctorGetPatientFullData(address patientAddress) public returns (
        string memory personalDataHash, 
        string memory medicalDataHash, 
        string memory visionDataHash
    ) {
        // Access control checks
        require(
            assignedGeneralDoctorList[patientAddress].isAllowed[msg.sender],
            "Not authorized to read this patient's data"
        );

        personalDataHash = patientBasicPersonalDataEncodes[patientAddress];
        medicalDataHash = patientBasicMedicalDataEncodes[patientAddress];
        visionDataHash = patientBasicVisionDataEncodes[patientAddress];

        emit DoctorDataAccessed(msg.sender, patientAddress, personalDataHash, medicalDataHash, visionDataHash);
    }

    // Allows general doctor to set medical doctor to patient
    function generalDoctorPostMedicalDoctorAddress(address patientAddress, address doctorAddress) public {
        // Access control checks
        require(
            assignedGeneralDoctorList[patientAddress].isAllowed[msg.sender],
            "Not authorized to grant this patient's data"
        );

        medicalDataAccessList[patientAddress].allowedDoctorList.push(doctorAddress);
        medicalDataAccessList[patientAddress].isAllowed[doctorAddress] = true;
    }

    // Allows general doctor to set vision doctor to patient
    function generalDoctorPostVisionDoctorAddress(address patientAddress, address doctorAddress) public {
         // Access control checks
        require(
            assignedGeneralDoctorList[patientAddress].isAllowed[msg.sender],
            "Not authorized to grant this patient's data"
        );

        visionDataAccessList[patientAddress].allowedDoctorList.push(doctorAddress);
        visionDataAccessList[patientAddress].isAllowed[doctorAddress] = true;
    }

    // Medical doctor functions

    // Allows medical doctor to request only medical data about patient
    function medicalDoctorGetPatientMedicalData(address patientAddress) public returns (string memory medicalDataHash) {
    // Access control checks
        require(
            medicalDataAccessList[patientAddress].isAllowed[msg.sender],
            "Not authorized to read this patient's data"
        );

        medicalDataHash = patientBasicMedicalDataEncodes[patientAddress];

        // Emitting the event with only relevant data fields
        emit DoctorDataAccessed(msg.sender, patientAddress, "", medicalDataHash, "");
    }

    // Vision doctor functions

    // Allows vision doctor to request only medical data about patient
    function visionDoctorGetPatientVisionData(address patientAddress) public returns (string memory visionDataHash) {
        // Access control checks
        require(
            visionDataAccessList[patientAddress].isAllowed[msg.sender],
            "Not authorized to read this patient's data"
        );

        visionDataHash = patientBasicVisionDataEncodes[patientAddress];  // Corrected to vision data

        // Emitting the event with only relevant data fields
        emit DoctorDataAccessed(msg.sender, patientAddress, "", "", visionDataHash);
    }

    // Functions for general and specialized doctors to access and update patient data

    // Allows general doctor or appointed personal doctors to update patient basic data
    function doctorUpdatePatientBasicPersonalData (
        address patientAddress,
        string memory national_id,
        string memory first_name,
        string memory last_name,
        string memory gender,
        string memory date_of_birth,
        string memory contact_phone
    ) public {

        // Access control to check if assigned general doctor or allowed personal doctor
        require(
            assignedGeneralDoctorList[patientAddress].isAllowed[msg.sender]
            || personalDataAccessList[patientAddress].isAllowed[msg.sender]
            , "Not authorized to update this patient's data"
        );

        // Call the inherited function to update and hash the patient's personal data
        updateAndEncodePatientBasicPersonalData(
            patientAddress,
            national_id,
            first_name,
            last_name,
            gender,
            date_of_birth,
            contact_phone
        );
    }

    // Allows general doctor or appointed medical doctors to update patient basic data
    function doctorUpdatePatientBasicMedicalData (
        address patientAddress,
        string memory height,
        string memory weight,
        string memory chronic_diseases,
        string memory health_concerns
    ) public {

        // Access control to check if assigned general doctor or allowed medical doctor
        require(
            assignedGeneralDoctorList[patientAddress].isAllowed[msg.sender]
            || medicalDataAccessList[patientAddress].isAllowed[msg.sender]
            , "Not authorized to update this patient's data"
        );

        // Call the inherited function to update and hash the patient's personal data
        updateAndEncodePatientBasicMedicalData(
            patientAddress,
            height,
            weight,
            chronic_diseases,
            health_concerns
        );
    }

    // Allows general doctor or appointed medical doctors to update patient basic data
    function doctorUpdatePatientBasicVisionData (
        address patientAddress,
        string memory eye_color,
        string memory eye_diseases_history,
        string memory vision_metrics
    ) public {

        // Access control to check if assigned general doctor or allowed vision doctor
        require(
            assignedGeneralDoctorList[patientAddress].isAllowed[msg.sender]
            || visionDataAccessList[patientAddress].isAllowed[msg.sender]
            , "Not authorized to update this patient's data"
        );

        // Call the inherited function to update and hash the patient's personal data
        updateAndEncodepatientBasicVisionData(
            patientAddress,
            eye_color,
            eye_diseases_history,
            vision_metrics
        );
    }

    string internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {
        if (data.length == 0) return "";

        // Concatenate a new full-length string
        string memory table = TABLE;
        uint256 encodedLen = 4 * ((data.length + 2) / 3);
        string memory result = new string(encodedLen + 32);

        assembly {
            mstore(result, encodedLen)

            let tablePtr := add(table, 1)
            let dataPtr := data
            let endPtr := add(dataPtr, mload(data))
            let resultPtr := add(result, 32)

            for {} lt(dataPtr, endPtr) {}
            {
                dataPtr := add(dataPtr, 3)
                let input := mload(dataPtr)

                mstore8(resultPtr, mload(add(tablePtr, and(shr(18, input), 0x3F))))
                resultPtr := add(resultPtr, 1)

                mstore8(resultPtr, mload(add(tablePtr, and(shr(12, input), 0x3F))))
                resultPtr := add(resultPtr, 1)

                mstore8(resultPtr, mload(add(tablePtr, and(shr(6, input), 0x3F))))
                resultPtr := add(resultPtr, 1)

                mstore8(resultPtr, mload(add(tablePtr, and(input, 0x3F))))
                resultPtr := add(resultPtr, 1)
            }
        }

        return result;
    }

}
