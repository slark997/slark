CREATE DATABASE HospitalDB;

CREATE TABLE Doctors (
  doctor_id INT PRIMARY KEY,
  name VARCHAR(100),
  specialization VARCHAR(100)
);

CREATE TABLE Wards (
  ward_id INT PRIMARY KEY,
  ward_name VARCHAR(100),
  beds_available INT
);

CREATE TABLE Patients (
  patient_id INT PRIMARY KEY,
  name VARCHAR(100),
  admission_date DATE,
  discharge_date DATE,
  condition VARCHAR(100),
  diagnosis VARCHAR(100),
  ward_id INT,
  doctor_id INT,
  FOREIGN KEY (ward_id) REFERENCES Wards(ward_id),
  FOREIGN KEY (doctor_id) REFERENCES Doctors(doctor_id),
);
