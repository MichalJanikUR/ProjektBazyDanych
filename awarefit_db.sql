--
-- PostgreSQL database dump
--

\restrict Qy4bmO4P9g5azUjHxNLyTuvTPyLe3zDWOcZ4zPhaxAyTkgd17FWgCU4rhN02lk3

-- Dumped from database version 18.1
-- Dumped by pg_dump version 18.1

-- Started on 2025-12-16 19:17:58

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 6 (class 2615 OID 24722)
-- Name: crud; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA crud;


ALTER SCHEMA crud OWNER TO postgres;

--
-- TOC entry 4 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: pg_database_owner
--

CREATE SCHEMA public;


ALTER SCHEMA public OWNER TO pg_database_owner;

--
-- TOC entry 5115 (class 0 OID 0)
-- Dependencies: 4
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: pg_database_owner
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 267 (class 1255 OID 24738)
-- Name: delete_body_measurement(integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.delete_body_measurement(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM body_measurements
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.delete_body_measurement(IN p_id integer) OWNER TO postgres;

--
-- TOC entry 235 (class 1255 OID 24734)
-- Name: delete_exercise(integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.delete_exercise(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM exercises
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.delete_exercise(IN p_id integer) OWNER TO postgres;

--
-- TOC entry 247 (class 1255 OID 24730)
-- Name: delete_muscle_group(integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.delete_muscle_group(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM muscle_groups
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.delete_muscle_group(IN p_id integer) OWNER TO postgres;

--
-- TOC entry 243 (class 1255 OID 24726)
-- Name: delete_user(integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.delete_user(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM users
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.delete_user(IN p_id integer) OWNER TO postgres;

--
-- TOC entry 271 (class 1255 OID 24742)
-- Name: delete_workout(integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.delete_workout(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM workouts
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.delete_workout(IN p_id integer) OWNER TO postgres;

--
-- TOC entry 275 (class 1255 OID 24746)
-- Name: delete_workout_exercise(integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.delete_workout_exercise(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM workout_exercises
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.delete_workout_exercise(IN p_id integer) OWNER TO postgres;

--
-- TOC entry 279 (class 1255 OID 24750)
-- Name: delete_workout_set(integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.delete_workout_set(IN p_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    DELETE FROM workout_sets
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.delete_workout_set(IN p_id integer) OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 227 (class 1259 OID 16431)
-- Name: body_measurements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.body_measurements (
    id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone NOT NULL,
    height double precision,
    weight double precision,
    chest double precision,
    waist double precision,
    biceps double precision,
    thighs double precision,
    hips double precision
);


ALTER TABLE public.body_measurements OWNER TO postgres;

--
-- TOC entry 237 (class 1255 OID 24735)
-- Name: get_all_body_measurements(); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.get_all_body_measurements() RETURNS SETOF public.body_measurements
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM body_measurements;
END;
$$;


ALTER FUNCTION crud.get_all_body_measurements() OWNER TO postgres;

--
-- TOC entry 225 (class 1259 OID 16414)
-- Name: exercises; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exercises (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    description text,
    muscle_group_id integer NOT NULL
);


ALTER TABLE public.exercises OWNER TO postgres;

--
-- TOC entry 248 (class 1255 OID 24731)
-- Name: get_all_exercises(); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.get_all_exercises() RETURNS SETOF public.exercises
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM exercises;
END;
$$;


ALTER FUNCTION crud.get_all_exercises() OWNER TO postgres;

--
-- TOC entry 223 (class 1259 OID 16405)
-- Name: muscle_groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.muscle_groups (
    id integer NOT NULL,
    name character varying(50) NOT NULL
);


ALTER TABLE public.muscle_groups OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 24727)
-- Name: get_all_muscle_groups(); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.get_all_muscle_groups() RETURNS SETOF public.muscle_groups
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM muscle_groups;
END;
$$;


ALTER FUNCTION crud.get_all_muscle_groups() OWNER TO postgres;

--
-- TOC entry 221 (class 1259 OID 16390)
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id integer NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(255) NOT NULL,
    email character varying(100) NOT NULL,
    first_name character varying(50) NOT NULL,
    last_name character varying(50) NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- TOC entry 236 (class 1255 OID 24723)
-- Name: get_all_users(); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.get_all_users() RETURNS SETOF public.users
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM users;
END;
$$;


ALTER FUNCTION crud.get_all_users() OWNER TO postgres;

--
-- TOC entry 231 (class 1259 OID 16461)
-- Name: workout_exercises; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workout_exercises (
    id integer NOT NULL,
    workout_id integer NOT NULL,
    exercise_id integer NOT NULL
);


ALTER TABLE public.workout_exercises OWNER TO postgres;

--
-- TOC entry 272 (class 1255 OID 24743)
-- Name: get_all_workout_exercises(); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.get_all_workout_exercises() RETURNS SETOF public.workout_exercises
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM workout_exercises;
END;
$$;


ALTER FUNCTION crud.get_all_workout_exercises() OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 16481)
-- Name: workout_sets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workout_sets (
    id integer NOT NULL,
    workout_exercise_id integer NOT NULL,
    weight double precision,
    reps integer NOT NULL,
    set_number integer NOT NULL
);


ALTER TABLE public.workout_sets OWNER TO postgres;

--
-- TOC entry 276 (class 1255 OID 24747)
-- Name: get_all_workout_sets(); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.get_all_workout_sets() RETURNS SETOF public.workout_sets
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM workout_sets;
END;
$$;


ALTER FUNCTION crud.get_all_workout_sets() OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 16446)
-- Name: workouts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.workouts (
    id integer NOT NULL,
    user_id integer NOT NULL,
    date timestamp without time zone NOT NULL
);


ALTER TABLE public.workouts OWNER TO postgres;

--
-- TOC entry 268 (class 1255 OID 24739)
-- Name: get_all_workouts(); Type: FUNCTION; Schema: crud; Owner: postgres
--

CREATE FUNCTION crud.get_all_workouts() RETURNS SETOF public.workouts
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY SELECT * FROM workouts;
END;
$$;


ALTER FUNCTION crud.get_all_workouts() OWNER TO postgres;

--
-- TOC entry 265 (class 1255 OID 24736)
-- Name: insert_body_measurement(integer, timestamp without time zone, double precision, double precision, double precision, double precision, double precision, double precision, double precision); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_body_measurement(IN p_user_id integer, IN p_date timestamp without time zone, IN p_height double precision, IN p_weight double precision, IN p_chest double precision, IN p_waist double precision, IN p_biceps double precision, IN p_thighs double precision, IN p_hips double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO body_measurements (user_id, date, height, weight, chest, waist, biceps, thighs, hips)
    VALUES (p_user_id, p_date, p_height, p_weight, p_chest, p_waist, p_biceps, p_thighs, p_hips);
END;
$$;


ALTER PROCEDURE crud.insert_body_measurement(IN p_user_id integer, IN p_date timestamp without time zone, IN p_height double precision, IN p_weight double precision, IN p_chest double precision, IN p_waist double precision, IN p_biceps double precision, IN p_thighs double precision, IN p_hips double precision) OWNER TO postgres;

--
-- TOC entry 249 (class 1255 OID 24732)
-- Name: insert_exercise(character varying, text, integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_exercise(IN p_name character varying, IN p_description text, IN p_muscle_group_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO exercises (name, description, muscle_group_id)
    VALUES (p_name, p_description, p_muscle_group_id);
END;
$$;


ALTER PROCEDURE crud.insert_exercise(IN p_name character varying, IN p_description text, IN p_muscle_group_id integer) OWNER TO postgres;

--
-- TOC entry 245 (class 1255 OID 24728)
-- Name: insert_muscle_group(character varying); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_muscle_group(IN p_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO muscle_groups (name)
    VALUES (p_name);
END;
$$;


ALTER PROCEDURE crud.insert_muscle_group(IN p_name character varying) OWNER TO postgres;

--
-- TOC entry 239 (class 1255 OID 24724)
-- Name: insert_user(character varying, character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_user(IN p_username character varying, IN p_password character varying, IN p_email character varying, IN p_first_name character varying, IN p_last_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO users (username, password, email, first_name, last_name)
    VALUES (p_username, p_password, p_email, p_first_name, p_last_name);
END;
$$;


ALTER PROCEDURE crud.insert_user(IN p_username character varying, IN p_password character varying, IN p_email character varying, IN p_first_name character varying, IN p_last_name character varying) OWNER TO postgres;

--
-- TOC entry 269 (class 1255 OID 24740)
-- Name: insert_workout(integer, timestamp without time zone); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_workout(IN p_user_id integer, IN p_date timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO workouts (user_id, date)
    VALUES (p_user_id, p_date);
END;
$$;


ALTER PROCEDURE crud.insert_workout(IN p_user_id integer, IN p_date timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 273 (class 1255 OID 24744)
-- Name: insert_workout_exercise(integer, integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_workout_exercise(IN p_workout_id integer, IN p_exercise_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO workout_exercises (workout_id, exercise_id)
    VALUES (p_workout_id, p_exercise_id);
END;
$$;


ALTER PROCEDURE crud.insert_workout_exercise(IN p_workout_id integer, IN p_exercise_id integer) OWNER TO postgres;

--
-- TOC entry 277 (class 1255 OID 24748)
-- Name: insert_workout_set(integer, double precision, integer, integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.insert_workout_set(IN p_workout_exercise_id integer, IN p_weight double precision, IN p_reps integer, IN p_set_number integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO workout_sets (workout_exercise_id, weight, reps, set_number)
    VALUES (p_workout_exercise_id, p_weight, p_reps, p_set_number);
END;
$$;


ALTER PROCEDURE crud.insert_workout_set(IN p_workout_exercise_id integer, IN p_weight double precision, IN p_reps integer, IN p_set_number integer) OWNER TO postgres;

--
-- TOC entry 266 (class 1255 OID 24737)
-- Name: update_body_measurement(integer, integer, timestamp without time zone, double precision, double precision, double precision, double precision, double precision, double precision, double precision); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.update_body_measurement(IN p_id integer, IN p_user_id integer, IN p_date timestamp without time zone, IN p_height double precision, IN p_weight double precision, IN p_chest double precision, IN p_waist double precision, IN p_biceps double precision, IN p_thighs double precision, IN p_hips double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE body_measurements
    SET
        user_id = p_user_id,
        date = p_date,
        height = p_height,
        weight = p_weight,
        chest = p_chest,
        waist = p_waist,
        biceps = p_biceps,
        thighs = p_thighs,
        hips = p_hips
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.update_body_measurement(IN p_id integer, IN p_user_id integer, IN p_date timestamp without time zone, IN p_height double precision, IN p_weight double precision, IN p_chest double precision, IN p_waist double precision, IN p_biceps double precision, IN p_thighs double precision, IN p_hips double precision) OWNER TO postgres;

--
-- TOC entry 250 (class 1255 OID 24733)
-- Name: update_exercise(integer, character varying, text, integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.update_exercise(IN p_id integer, IN p_name character varying, IN p_description text, IN p_muscle_group_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE exercises
    SET
        name = p_name,
        description = p_description,
        muscle_group_id = p_muscle_group_id
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.update_exercise(IN p_id integer, IN p_name character varying, IN p_description text, IN p_muscle_group_id integer) OWNER TO postgres;

--
-- TOC entry 246 (class 1255 OID 24729)
-- Name: update_muscle_group(integer, character varying); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.update_muscle_group(IN p_id integer, IN p_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE muscle_groups
    SET
        name = p_name
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.update_muscle_group(IN p_id integer, IN p_name character varying) OWNER TO postgres;

--
-- TOC entry 242 (class 1255 OID 24725)
-- Name: update_user(integer, character varying, character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.update_user(IN p_id integer, IN p_username character varying, IN p_password character varying, IN p_email character varying, IN p_first_name character varying, IN p_last_name character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE users
    SET
        username = p_username,
        password = p_password,
        email = p_email,
        first_name = p_first_name,
        last_name = p_last_name
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.update_user(IN p_id integer, IN p_username character varying, IN p_password character varying, IN p_email character varying, IN p_first_name character varying, IN p_last_name character varying) OWNER TO postgres;

--
-- TOC entry 270 (class 1255 OID 24741)
-- Name: update_workout(integer, integer, timestamp without time zone); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.update_workout(IN p_id integer, IN p_user_id integer, IN p_date timestamp without time zone)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE workouts
    SET
        user_id = p_user_id,
        date = p_date
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.update_workout(IN p_id integer, IN p_user_id integer, IN p_date timestamp without time zone) OWNER TO postgres;

--
-- TOC entry 274 (class 1255 OID 24745)
-- Name: update_workout_exercise(integer, integer, integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.update_workout_exercise(IN p_id integer, IN p_workout_id integer, IN p_exercise_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE workout_exercises
    SET
        workout_id = p_workout_id,
        exercise_id = p_exercise_id
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.update_workout_exercise(IN p_id integer, IN p_workout_id integer, IN p_exercise_id integer) OWNER TO postgres;

--
-- TOC entry 278 (class 1255 OID 24749)
-- Name: update_workout_set(integer, integer, double precision, integer, integer); Type: PROCEDURE; Schema: crud; Owner: postgres
--

CREATE PROCEDURE crud.update_workout_set(IN p_id integer, IN p_workout_exercise_id integer, IN p_weight double precision, IN p_reps integer, IN p_set_number integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE workout_sets
    SET
        workout_exercise_id = p_workout_exercise_id,
        weight = p_weight,
        reps = p_reps,
        set_number = p_set_number
    WHERE id = p_id;
END;
$$;


ALTER PROCEDURE crud.update_workout_set(IN p_id integer, IN p_workout_exercise_id integer, IN p_weight double precision, IN p_reps integer, IN p_set_number integer) OWNER TO postgres;

--
-- TOC entry 240 (class 1255 OID 16511)
-- Name: create_body_measurement(integer, timestamp without time zone, double precision, double precision, double precision, double precision, double precision, double precision, double precision); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.create_body_measurement(IN p_user_id integer, IN p_date timestamp without time zone, IN p_height double precision, IN p_weight double precision, IN p_chest double precision, IN p_waist double precision, IN p_biceps double precision, IN p_thighs double precision, IN p_hips double precision, OUT p_measurement_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    INSERT INTO body_measurements (user_id, date, height, weight, chest, waist, biceps, thighs, hips)
    VALUES (p_user_id, p_date, p_height, p_weight, p_chest, p_waist, p_biceps, p_thighs, p_hips)
    RETURNING id INTO p_measurement_id;

    RAISE NOTICE 'Dodano pomiar o ID % dla użytkownika % w dniu %.', p_measurement_id, p_user_id, p_date;
END;
$$;


ALTER PROCEDURE public.create_body_measurement(IN p_user_id integer, IN p_date timestamp without time zone, IN p_height double precision, IN p_weight double precision, IN p_chest double precision, IN p_waist double precision, IN p_biceps double precision, IN p_thighs double precision, IN p_hips double precision, OUT p_measurement_id integer) OWNER TO postgres;

--
-- TOC entry 238 (class 1255 OID 16507)
-- Name: create_user(character varying, character varying, character varying, character varying, character varying); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.create_user(IN p_username character varying, IN p_password character varying, IN p_email character varying, IN p_first_name character varying, IN p_last_name character varying, OUT p_user_id integer)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Wstawienie nowego użytkownika
    INSERT INTO users (username, password, email, first_name, last_name)
    VALUES (p_username, p_password, p_email, p_first_name, p_last_name)
    RETURNING id INTO p_user_id;

    RAISE NOTICE 'Utworzono nowego użytkownika: % (ID: %)', p_username, p_user_id;
EXCEPTION
    -- Obsługa błędu unikalności (jeśli username lub email są unikalne)
    WHEN unique_violation THEN
        RAISE EXCEPTION 'Błąd rejestracji: Nazwa użytkownika lub adres email są już zajęte.';
END;
$$;


ALTER PROCEDURE public.create_user(IN p_username character varying, IN p_password character varying, IN p_email character varying, IN p_first_name character varying, IN p_last_name character varying, OUT p_user_id integer) OWNER TO postgres;

--
-- TOC entry 241 (class 1255 OID 16517)
-- Name: get_detailed_workout(integer, integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_detailed_workout(p_user_id integer, p_workout_id integer) RETURNS TABLE(workout_id integer, workout_date timestamp without time zone, exercise_name character varying, set_number integer, weight double precision, reps integer)
    LANGUAGE sql
    AS $$
    SELECT
        w.id AS workout_id,
        w.date AS workout_date,
        e.name AS exercise_name,
        ws.set_number,
        ws.weight,
        ws.reps
    FROM 
        workouts w
    JOIN 
        workout_exercises we ON w.id = we.workout_id
    JOIN
        exercises e ON we.exercise_id = e.id
    JOIN 
        workout_sets ws ON we.id = ws.workout_exercise_id
    WHERE
        w.id = p_workout_id
        AND w.user_id = p_user_id -- Zabezpieczenie: upewnij się, że trening należy do tego użytkownika
    ORDER BY
        w.date, e.name, ws.set_number;
$$;


ALTER FUNCTION public.get_detailed_workout(p_user_id integer, p_workout_id integer) OWNER TO postgres;

--
-- TOC entry 263 (class 1255 OID 16516)
-- Name: get_exercises_by_muscle_group(character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_exercises_by_muscle_group(p_muscle_group_name character varying) RETURNS TABLE(exercise_id integer, exercise_name character varying, muscle_group_name character varying)
    LANGUAGE sql
    AS $$
    SELECT 
        e.id, 
        e.name, 
        mg.name
    FROM 
        exercises e
    JOIN 
        muscle_groups mg ON e.muscle_group_id = mg.id
    WHERE
        mg.name ILIKE p_muscle_group_name -- Wyszukiwanie bez względu na wielkość liter (ILIKE)
    ORDER BY
        e.name;
$$;


ALTER FUNCTION public.get_exercises_by_muscle_group(p_muscle_group_name character varying) OWNER TO postgres;

--
-- TOC entry 264 (class 1255 OID 16514)
-- Name: get_user_measurements(integer); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.get_user_measurements(p_user_id integer) RETURNS TABLE(measurement_id integer, date timestamp without time zone, height double precision, weight double precision, chest double precision, waist double precision, biceps double precision, thighs double precision, hips double precision)
    LANGUAGE sql
    AS $$
    SELECT 
        bm.id,
        bm.date,
        bm.height,
        bm.weight,
        bm.chest,
        bm.waist,
        bm.biceps,
        bm.thighs,
        bm.hips
    FROM 
        body_measurements bm
    WHERE 
        bm.user_id = p_user_id
    ORDER BY
        bm.date ASC; -- Sortowanie chronologiczne
$$;


ALTER FUNCTION public.get_user_measurements(p_user_id integer) OWNER TO postgres;

--
-- TOC entry 234 (class 1255 OID 16506)
-- Name: login_by_username(character varying, character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.login_by_username(p_username character varying, p_password character varying) RETURNS TABLE(user_id integer, first_name character varying)
    LANGUAGE sql
    AS $$
    SELECT u.id, u.first_name
    FROM users u
    WHERE u.username = p_username
      AND u.password = p_password;
$$;


ALTER FUNCTION public.login_by_username(p_username character varying, p_password character varying) OWNER TO postgres;

--
-- TOC entry 262 (class 1255 OID 16512)
-- Name: update_body_measurement(integer, double precision, double precision, double precision, double precision, double precision, double precision, double precision); Type: PROCEDURE; Schema: public; Owner: postgres
--

CREATE PROCEDURE public.update_body_measurement(IN p_measurement_id integer, IN p_new_height double precision DEFAULT NULL::double precision, IN p_new_weight double precision DEFAULT NULL::double precision, IN p_new_chest double precision DEFAULT NULL::double precision, IN p_new_waist double precision DEFAULT NULL::double precision, IN p_new_biceps double precision DEFAULT NULL::double precision, IN p_new_thighs double precision DEFAULT NULL::double precision, IN p_new_hips double precision DEFAULT NULL::double precision)
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE body_measurements
    SET 
        height = COALESCE(p_new_height, height),
        weight = COALESCE(p_new_weight, weight),
        chest = COALESCE(p_new_chest, chest),
        waist = COALESCE(p_new_waist, waist),
        biceps = COALESCE(p_new_biceps, biceps),
        thighs = COALESCE(p_new_thighs, thighs),
        hips = COALESCE(p_new_hips, hips)
    WHERE 
        id = p_measurement_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Błąd: Pomiar o ID % nie został znaleziony.', p_measurement_id;
    ELSE
        RAISE NOTICE 'Zaktualizowano pomiar o ID: %', p_measurement_id;
    END IF;
END;
$$;


ALTER PROCEDURE public.update_body_measurement(IN p_measurement_id integer, IN p_new_height double precision, IN p_new_weight double precision, IN p_new_chest double precision, IN p_new_waist double precision, IN p_new_biceps double precision, IN p_new_thighs double precision, IN p_new_hips double precision) OWNER TO postgres;

--
-- TOC entry 226 (class 1259 OID 16430)
-- Name: body_measurements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.body_measurements_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.body_measurements_id_seq OWNER TO postgres;

--
-- TOC entry 5116 (class 0 OID 0)
-- Dependencies: 226
-- Name: body_measurements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.body_measurements_id_seq OWNED BY public.body_measurements.id;


--
-- TOC entry 224 (class 1259 OID 16413)
-- Name: exercises_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.exercises_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.exercises_id_seq OWNER TO postgres;

--
-- TOC entry 5117 (class 0 OID 0)
-- Dependencies: 224
-- Name: exercises_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.exercises_id_seq OWNED BY public.exercises.id;


--
-- TOC entry 222 (class 1259 OID 16404)
-- Name: muscle_groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.muscle_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.muscle_groups_id_seq OWNER TO postgres;

--
-- TOC entry 5118 (class 0 OID 0)
-- Dependencies: 222
-- Name: muscle_groups_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.muscle_groups_id_seq OWNED BY public.muscle_groups.id;


--
-- TOC entry 220 (class 1259 OID 16389)
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- TOC entry 5119 (class 0 OID 0)
-- Dependencies: 220
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- TOC entry 230 (class 1259 OID 16460)
-- Name: workout_exercises_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workout_exercises_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workout_exercises_id_seq OWNER TO postgres;

--
-- TOC entry 5120 (class 0 OID 0)
-- Dependencies: 230
-- Name: workout_exercises_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workout_exercises_id_seq OWNED BY public.workout_exercises.id;


--
-- TOC entry 232 (class 1259 OID 16480)
-- Name: workout_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workout_sets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workout_sets_id_seq OWNER TO postgres;

--
-- TOC entry 5121 (class 0 OID 0)
-- Dependencies: 232
-- Name: workout_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workout_sets_id_seq OWNED BY public.workout_sets.id;


--
-- TOC entry 228 (class 1259 OID 16445)
-- Name: workouts_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.workouts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.workouts_id_seq OWNER TO postgres;

--
-- TOC entry 5122 (class 0 OID 0)
-- Dependencies: 228
-- Name: workouts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.workouts_id_seq OWNED BY public.workouts.id;


--
-- TOC entry 4925 (class 2604 OID 16434)
-- Name: body_measurements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.body_measurements ALTER COLUMN id SET DEFAULT nextval('public.body_measurements_id_seq'::regclass);


--
-- TOC entry 4924 (class 2604 OID 16417)
-- Name: exercises id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exercises ALTER COLUMN id SET DEFAULT nextval('public.exercises_id_seq'::regclass);


--
-- TOC entry 4923 (class 2604 OID 16408)
-- Name: muscle_groups id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.muscle_groups ALTER COLUMN id SET DEFAULT nextval('public.muscle_groups_id_seq'::regclass);


--
-- TOC entry 4922 (class 2604 OID 16393)
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- TOC entry 4927 (class 2604 OID 16464)
-- Name: workout_exercises id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout_exercises ALTER COLUMN id SET DEFAULT nextval('public.workout_exercises_id_seq'::regclass);


--
-- TOC entry 4928 (class 2604 OID 16484)
-- Name: workout_sets id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout_sets ALTER COLUMN id SET DEFAULT nextval('public.workout_sets_id_seq'::regclass);


--
-- TOC entry 4926 (class 2604 OID 16449)
-- Name: workouts id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workouts ALTER COLUMN id SET DEFAULT nextval('public.workouts_id_seq'::regclass);


--
-- TOC entry 5103 (class 0 OID 16431)
-- Dependencies: 227
-- Data for Name: body_measurements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.body_measurements (id, user_id, date, height, weight, chest, waist, biceps, thighs, hips) FROM stdin;
1	1	2025-11-26 16:52:38.017785	180	85.5	105	90	38	60	100
2	2	2025-11-26 16:52:38.017785	165	58	88	65	28	52	92
3	3	2025-11-26 16:52:38.017785	178	92	110	95	41	65	102
4	4	2025-11-26 16:52:38.017785	170	62.5	90	68	29	55	95
5	5	2025-11-26 16:52:38.017785	185	78	100	82	36	58	98
\.


--
-- TOC entry 5101 (class 0 OID 16414)
-- Dependencies: 225
-- Data for Name: exercises; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.exercises (id, name, description, muscle_group_id) FROM stdin;
1	Pompki klasyczne	\N	1
2	Rozpiętki na maszynie	\N	1
3	Rozpiętki z hantlami na ławce płaskiej	\N	1
4	Rozpiętki z hantlami na ławce skośnej	\N	1
5	Rozpiętki z linkami na bramie	\N	1
6	Wyciskanie sztangi na ławce płaskiej	\N	1
7	Wyciskanie sztangi na ławce skośnej	\N	1
8	Wyciskanie sztangi na maszynie Smith na ławce płaskiej	\N	1
9	Wyciskanie sztangi na maszynie Smith na ławce skośnej	\N	1
10	Wyciskanie hantli na ławce płaskiej	\N	1
11	Wyciskanie hantli na ławce skośnej	\N	1
12	Wyciskanie na maszynie hammer	\N	1
13	Podciąganie chwytem neutralny	\N	2
14	Podciąganie nachwytem	\N	2
15	Podciąganie podchwytem	\N	2
16	Ściąganie drążka wyciągu górnego do klatki	\N	2
17	Ściąganie drążka wyciągu górnego prostymi rękami	\N	2
18	Wiosłowanie sztangą	\N	2
19	Wiosłowanie hantlą jednorącz	\N	2
20	Wiosłowanie hantlami	\N	2
21	Wiosłowanie na maszynie	\N	2
22	Wiosłowanie linką wyciągu	\N	2
23	Ściąganie linki wyciągu górnego jednorącz	\N	2
24	Wiosłowanie z linką wyciągu dolnego	\N	2
25	Wiosłowanie T-bar	\N	2
26	Facepull	\N	3
27	Odwrotne rozpiętki na maszynie	\N	3
28	Wyciskanie żołnierskie z przed głowy	\N	3
29	Wznosy bokiem z hantlami	\N	3
30	Wznosy bokiem z linką wyciągu	\N	3
31	Unoszenie ramion w bok na maszynie	\N	3
32	Wznosy bokiem z hantlami w opadzie tułowia	\N	3
33	Wznosy bokiem z linką wyciągu w opadzie	\N	3
34	Wyciskanie hantli nad głowę	\N	3
35	Wyciskanie na maszynie Smitha	\N	3
36	Pompki na poręczach	\N	4
37	Prostowanie ramion na wyciągu górnym	\N	4
38	Prostowanie ramion z za głowy	\N	4
39	Prostowanie ramion na maszynie	\N	4
40	Wyciskanie francuskie hantlami	\N	4
41	Wyciskanie francuskie sztangą	\N	4
42	Młotkowe uginanie ramion z hantlami	\N	5
43	Uginanie ramion z hantlami stojąc	\N	5
44	Uginanie ramion z hantlami siedząc	\N	5
45	Uginanie ramion na maszynie	\N	5
46	Uginanie ramion ze sztangą	\N	5
47	Uginanie ramion z hantlami na modlitewniku	\N	5
48	Uginanie ramion z hantlą w podporze o kolano	\N	5
49	Uginanie ramion na wyciągu dolnym	\N	5
50	Prostowanie nadgarstka z hantlą siedząc	\N	9
51	Uginanie nadgarstka ze sztangą	\N	9
52	Wrist roller	\N	9
53	Kickback na wyciągu	\N	6
54	Hip thrust ze sztangą	\N	6
55	Hip thrust na maszynie	\N	6
56	Hip thrust jednonóż	\N	6
57	Martwy ciąg na prostych nogach ze sztangą	\N	6
58	Martwy ciąg na prostych nogach jednonóż z hantlą	\N	6
59	Martwy ciąg klasyczny	\N	6
60	Martwy ciąg sumo	\N	6
61	Nordic hamstring curl	\N	6
62	Odwodzenie nóg na maszynie	\N	6
63	Odwodzenie nogi w bok ma lince wyciągu	\N	6
64	Prostowanie nóg na maszynie	\N	6
65	Prostowanie nóg na suwnicy	\N	6
66	Przysiad bułgarski z hantlami	\N	6
67	Przysiad bułgarski ze sztangą	\N	6
68	Przysiad na maszynie Smith	\N	6
69	Przysiad klasyczny ze sztangą	\N	6
70	Goblet Squat	\N	6
71	Przywodzenie nóg na maszynie	\N	6
72	Skłony ze sztangą	\N	6
73	Wchodzenie na skrzynię z obciążeniem	\N	6
74	Wykroki z hantlami	\N	6
75	Zakroki z hantlami	\N	6
76	Wykroki ze sztangą	\N	6
77	Zakroki ze sztangą	\N	6
78	Przysiad na maszynie	\N	6
79	Zginanie podudzi na maszynie	\N	6
80	Brzuszki	\N	7
81	Brzuszki (kolano do łokcia)	\N	7
82	Ćwiczenie z wykorzystaniem kółka	\N	7
83	Deska	\N	7
84	Hollow Body	\N	7
85	Wspinaczka	\N	7
86	Nożyce	\N	7
87	Allahy na wyciągu górnym	\N	7
88	Deska bokiem	\N	7
89	Russian twist	\N	7
90	Skłony bokiem z hantlą stojąc	\N	7
91	Skłony bokiem z linką wyciągu	\N	7
92	Przyciąganie kolan do klatki siedząc	\N	7
93	Przyciąganie kolan do klatki na maszynie	\N	7
94	Unoszenie nóg na maszynie	\N	7
95	Unoszenie nóg na drążku	\N	7
96	Unoszenie nóg leżąc	\N	7
97	Spięcia brzucha na maszynie	\N	7
98	Wznosy nóg na poręczach	\N	7
99	Wspięcia na palce na maszynie Smith	\N	8
100	Wspięcia na palce na suwnicy	\N	8
101	Wspięcia na palce z hantlem siedząc	\N	8
102	Wypychanie palcami na maszynie	\N	8
103	Wspięcia na palce na stopniu	\N	8
\.


--
-- TOC entry 5099 (class 0 OID 16405)
-- Dependencies: 223
-- Data for Name: muscle_groups; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.muscle_groups (id, name) FROM stdin;
1	Klatka piersiowa
2	Plecy
3	Barki
4	Triceps
5	Biceps
6	Uda i pośladki
7	Brzuch
8	Łydki
9	Przedramię
\.


--
-- TOC entry 5097 (class 0 OID 16390)
-- Dependencies: 221
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, username, password, email, first_name, last_name) FROM stdin;
1	jan_kowalski	haslo123	jan.k@example.com	Jan	Kowalski
2	anna_nowak	bezpieczneHaslo	anna.n@example.com	Anna	Nowak
3	piotr_wisniewski	silownia2023	piotr.w@example.com	Piotr	Wiśniewski
4	kasia_lewandowska	fitness4life	kasia.l@example.com	Katarzyna	Lewandowska
5	michal_zielinski	trening1	michal.z@example.com	Michał	Zieliński
6	nowy_user	nowe_haslo	nowy@user.com	Test	Testowy
7	test	test	test@example.com	Test	Test
\.


--
-- TOC entry 5107 (class 0 OID 16461)
-- Dependencies: 231
-- Data for Name: workout_exercises; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workout_exercises (id, workout_id, exercise_id) FROM stdin;
1	1	6
2	1	34
3	1	29
4	1	37
5	2	11
6	2	29
7	2	37
8	2	6
9	3	6
10	3	34
11	3	29
12	3	37
13	3	11
14	4	18
15	4	16
16	4	19
17	4	46
18	5	16
19	5	19
20	5	46
21	6	18
22	6	16
23	6	19
24	6	46
25	7	69
26	7	54
27	7	87
28	7	59
29	8	59
30	8	54
31	8	87
32	8	69
33	9	69
34	9	59
35	9	54
36	9	87
37	10	6
38	10	34
39	10	29
40	10	37
41	11	11
42	11	29
43	11	37
44	11	6
45	12	6
46	12	34
47	12	29
48	12	37
49	12	11
50	13	18
51	13	16
52	13	19
53	13	46
54	14	16
55	14	19
56	14	46
57	15	18
58	15	16
59	15	19
60	15	46
61	16	69
62	16	54
63	16	87
64	16	59
65	17	59
66	17	54
67	17	87
68	17	69
69	18	69
70	18	59
71	18	54
72	18	87
73	19	6
74	19	34
75	19	29
76	19	37
77	20	11
78	20	29
79	20	37
80	20	6
81	21	6
82	21	34
83	21	29
84	21	37
85	21	11
86	22	18
87	22	16
88	22	19
89	22	46
90	23	16
91	23	19
92	23	46
93	24	18
94	24	16
95	24	19
96	24	46
97	25	11
98	25	16
99	25	69
100	25	37
101	25	46
102	25	87
103	26	6
104	26	18
105	26	59
106	26	34
107	26	46
108	27	11
109	27	16
110	27	69
111	27	37
112	27	46
113	27	87
114	28	6
115	28	18
116	28	59
117	28	34
118	28	46
119	29	11
120	29	16
121	29	69
122	29	37
123	29	46
124	29	87
125	30	6
126	30	18
127	30	59
128	30	34
129	30	46
130	31	11
131	31	16
132	31	69
133	31	37
134	31	46
135	31	87
136	32	6
137	32	18
138	32	59
139	32	34
140	32	46
141	33	11
142	33	16
143	33	69
144	33	37
145	33	46
146	33	87
147	34	6
148	34	18
149	34	59
150	34	34
151	34	46
152	35	11
153	35	16
154	35	69
155	35	37
156	35	46
157	35	87
158	36	6
159	36	18
160	36	59
161	36	34
162	36	46
\.


--
-- TOC entry 5109 (class 0 OID 16481)
-- Dependencies: 233
-- Data for Name: workout_sets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workout_sets (id, workout_exercise_id, weight, reps, set_number) FROM stdin;
1	1	80	9	1
2	1	80	9	2
3	1	80	9	3
4	1	80	9	4
5	2	80	8	1
6	2	80	8	2
7	2	80	8	3
8	3	80	10	1
9	3	80	10	2
10	3	80	10	3
11	4	80	11	1
12	4	80	11	2
13	4	80	11	3
14	4	80	11	4
15	5	15	10	1
16	5	15	10	2
17	5	15	10	3
18	6	15	13	1
19	6	15	13	2
20	6	15	13	3
21	7	15	12	1
22	7	15	12	2
23	7	15	12	3
24	8	15	13	1
25	8	15	13	2
26	8	15	13	3
27	8	15	13	4
28	9	95	8	1
29	9	95	8	2
30	9	95	8	3
31	10	95	8	1
32	10	95	8	2
33	10	95	8	3
34	10	95	8	4
35	11	95	6	1
36	11	95	6	2
37	11	95	6	3
38	12	95	8	1
39	12	95	8	2
40	12	95	8	3
41	13	95	8	1
42	13	95	8	2
43	13	95	8	3
44	13	95	8	4
45	14	70	10	1
46	14	70	10	2
47	14	70	10	3
48	15	70	9	1
49	15	70	9	2
50	15	70	9	3
51	16	70	10	1
52	16	70	10	2
53	16	70	10	3
54	17	70	9	1
55	17	70	9	2
56	17	70	9	3
57	17	70	9	4
58	18	40	12	1
59	18	40	12	2
60	18	40	12	3
61	18	40	12	4
62	19	40	12	1
63	19	40	12	2
64	19	40	12	3
65	20	40	12	1
66	20	40	12	2
67	20	40	12	3
68	20	40	12	4
69	21	85	7	1
70	21	85	7	2
71	21	85	7	3
72	22	85	7	1
73	22	85	7	2
74	22	85	7	3
75	23	85	8	1
76	23	85	8	2
77	23	85	8	3
78	23	85	8	4
79	24	85	6	1
80	24	85	6	2
81	24	85	6	3
82	25	100	10	1
83	25	100	10	2
84	25	100	10	3
85	26	100	12	1
86	26	100	12	2
87	26	100	12	3
88	27	100	10	1
89	27	100	10	2
90	27	100	10	3
91	27	100	10	4
92	28	100	8	1
93	28	100	8	2
94	28	100	8	3
95	28	100	8	4
96	29	50	11	1
97	29	50	11	2
98	29	50	11	3
99	30	50	12	1
100	30	50	12	2
101	30	50	12	3
102	31	50	10	1
103	31	50	10	2
104	31	50	10	3
105	31	50	10	4
106	32	50	14	1
107	32	50	14	2
108	32	50	14	3
109	32	50	14	4
110	33	120	9	1
111	33	120	9	2
112	33	120	9	3
113	33	120	9	4
114	34	120	8	1
115	34	120	8	2
116	34	120	8	3
117	35	120	7	1
118	35	120	7	2
119	35	120	7	3
120	36	120	7	1
121	36	120	7	2
122	36	120	7	3
123	36	120	7	4
124	37	80	9	1
125	37	80	9	2
126	37	80	9	3
127	38	80	8	1
128	38	80	8	2
129	38	80	8	3
130	39	80	9	1
131	39	80	9	2
132	39	80	9	3
133	39	80	9	4
134	40	80	12	1
135	40	80	12	2
136	40	80	12	3
137	41	15	11	1
138	41	15	11	2
139	41	15	11	3
140	41	15	11	4
141	42	15	14	1
142	42	15	14	2
143	42	15	14	3
144	42	15	14	4
145	43	15	10	1
146	43	15	10	2
147	43	15	10	3
148	43	15	10	4
149	44	15	14	1
150	44	15	14	2
151	44	15	14	3
152	45	95	8	1
153	45	95	8	2
154	45	95	8	3
155	45	95	8	4
156	46	95	7	1
157	46	95	7	2
158	46	95	7	3
159	46	95	7	4
160	47	95	6	1
161	47	95	6	2
162	47	95	6	3
163	47	95	6	4
164	48	95	9	1
165	48	95	9	2
166	48	95	9	3
167	48	95	9	4
168	49	95	8	1
169	49	95	8	2
170	49	95	8	3
171	50	70	8	1
172	50	70	8	2
173	50	70	8	3
174	50	70	8	4
175	51	70	10	1
176	51	70	10	2
177	51	70	10	3
178	52	70	8	1
179	52	70	8	2
180	52	70	8	3
181	53	70	12	1
182	53	70	12	2
183	53	70	12	3
184	53	70	12	4
185	54	40	10	1
186	54	40	10	2
187	54	40	10	3
188	54	40	10	4
189	55	40	14	1
190	55	40	14	2
191	55	40	14	3
192	56	40	14	1
193	56	40	14	2
194	56	40	14	3
195	56	40	14	4
196	57	85	8	1
197	57	85	8	2
198	57	85	8	3
199	57	85	8	4
200	58	85	8	1
201	58	85	8	2
202	58	85	8	3
203	59	85	6	1
204	59	85	6	2
205	59	85	6	3
206	60	85	9	1
207	60	85	9	2
208	60	85	9	3
209	60	85	9	4
210	61	100	12	1
211	61	100	12	2
212	61	100	12	3
213	62	100	9	1
214	62	100	9	2
215	62	100	9	3
216	62	100	9	4
217	63	100	10	1
218	63	100	10	2
219	63	100	10	3
220	63	100	10	4
221	64	100	9	1
222	64	100	9	2
223	64	100	9	3
224	64	100	9	4
225	65	50	10	1
226	65	50	10	2
227	65	50	10	3
228	66	50	12	1
229	66	50	12	2
230	66	50	12	3
231	66	50	12	4
232	67	50	13	1
233	67	50	13	2
234	67	50	13	3
235	68	50	11	1
236	68	50	11	2
237	68	50	11	3
238	69	120	8	1
239	69	120	8	2
240	69	120	8	3
241	69	120	8	4
242	70	120	7	1
243	70	120	7	2
244	70	120	7	3
245	70	120	7	4
246	71	120	9	1
247	71	120	9	2
248	71	120	9	3
249	71	120	9	4
250	72	120	9	1
251	72	120	9	2
252	72	120	9	3
253	72	120	9	4
254	73	80	8	1
255	73	80	8	2
256	73	80	8	3
257	73	80	8	4
258	74	80	10	1
259	74	80	10	2
260	74	80	10	3
261	74	80	10	4
262	75	80	10	1
263	75	80	10	2
264	75	80	10	3
265	76	80	11	1
266	76	80	11	2
267	76	80	11	3
268	76	80	11	4
269	77	15	12	1
270	77	15	12	2
271	77	15	12	3
272	78	15	14	1
273	78	15	14	2
274	78	15	14	3
275	78	15	14	4
276	79	15	13	1
277	79	15	13	2
278	79	15	13	3
279	80	15	14	1
280	80	15	14	2
281	80	15	14	3
282	81	95	7	1
283	81	95	7	2
284	81	95	7	3
285	81	95	7	4
286	82	95	9	1
287	82	95	9	2
288	82	95	9	3
289	82	95	9	4
290	83	95	9	1
291	83	95	9	2
292	83	95	9	3
293	84	95	8	1
294	84	95	8	2
295	84	95	8	3
296	84	95	8	4
297	85	95	8	1
298	85	95	8	2
299	85	95	8	3
300	86	70	12	1
301	86	70	12	2
302	86	70	12	3
303	87	70	12	1
304	87	70	12	2
305	87	70	12	3
306	87	70	12	4
307	88	70	8	1
308	88	70	8	2
309	88	70	8	3
310	88	70	8	4
311	89	70	11	1
312	89	70	11	2
313	89	70	11	3
314	89	70	11	4
315	90	40	11	1
316	90	40	11	2
317	90	40	11	3
318	90	40	11	4
319	91	40	12	1
320	91	40	12	2
321	91	40	12	3
322	92	40	10	1
323	92	40	10	2
324	92	40	10	3
325	93	85	6	1
326	93	85	6	2
327	93	85	6	3
328	93	85	6	4
329	94	85	9	1
330	94	85	9	2
331	94	85	9	3
332	94	85	9	4
333	95	85	9	1
334	95	85	9	2
335	95	85	9	3
336	96	85	8	1
337	96	85	8	2
338	96	85	8	3
339	97	10	11	1
340	97	10	11	2
341	97	10	11	3
342	97	10	11	4
343	98	10	13	1
344	98	10	13	2
345	98	10	13	3
346	98	10	13	4
347	99	10	10	1
348	99	10	10	2
349	99	10	10	3
350	100	10	13	1
351	100	10	13	2
352	100	10	13	3
353	100	10	13	4
354	101	10	12	1
355	101	10	12	2
356	101	10	12	3
357	102	10	13	1
358	102	10	13	2
359	102	10	13	3
360	103	65	12	1
361	103	65	12	2
362	103	65	12	3
363	103	65	12	4
364	104	65	9	1
365	104	65	9	2
366	104	65	9	3
367	105	65	9	1
368	105	65	9	2
369	105	65	9	3
370	105	65	9	4
371	106	65	9	1
372	106	65	9	2
373	106	65	9	3
374	106	65	9	4
375	107	65	9	1
376	107	65	9	2
377	107	65	9	3
378	108	10	14	1
379	108	10	14	2
380	108	10	14	3
381	108	10	14	4
382	109	10	11	1
383	109	10	11	2
384	109	10	11	3
385	109	10	11	4
386	110	10	11	1
387	110	10	11	2
388	110	10	11	3
389	110	10	11	4
390	111	10	12	1
391	111	10	12	2
392	111	10	12	3
393	111	10	12	4
394	112	10	14	1
395	112	10	14	2
396	112	10	14	3
397	112	10	14	4
398	113	10	11	1
399	113	10	11	2
400	113	10	11	3
401	113	10	11	4
402	114	65	10	1
403	114	65	10	2
404	114	65	10	3
405	114	65	10	4
406	115	65	10	1
407	115	65	10	2
408	115	65	10	3
409	115	65	10	4
410	116	65	8	1
411	116	65	8	2
412	116	65	8	3
413	117	65	12	1
414	117	65	12	2
415	117	65	12	3
416	117	65	12	4
417	118	65	9	1
418	118	65	9	2
419	118	65	9	3
420	118	65	9	4
421	119	10	10	1
422	119	10	10	2
423	119	10	10	3
424	120	10	11	1
425	120	10	11	2
426	120	10	11	3
427	120	10	11	4
428	121	10	11	1
429	121	10	11	2
430	121	10	11	3
431	122	10	10	1
432	122	10	10	2
433	122	10	10	3
434	122	10	10	4
435	123	10	11	1
436	123	10	11	2
437	123	10	11	3
438	123	10	11	4
439	124	10	13	1
440	124	10	13	2
441	124	10	13	3
442	124	10	13	4
443	125	65	11	1
444	125	65	11	2
445	125	65	11	3
446	125	65	11	4
447	126	65	11	1
448	126	65	11	2
449	126	65	11	3
450	127	65	9	1
451	127	65	9	2
452	127	65	9	3
453	128	65	12	1
454	128	65	12	2
455	128	65	12	3
456	129	65	9	1
457	129	65	9	2
458	129	65	9	3
459	129	65	9	4
460	130	10	14	1
461	130	10	14	2
462	130	10	14	3
463	130	10	14	4
464	131	10	10	1
465	131	10	10	2
466	131	10	10	3
467	132	10	14	1
468	132	10	14	2
469	132	10	14	3
470	133	10	11	1
471	133	10	11	2
472	133	10	11	3
473	133	10	11	4
474	134	10	11	1
475	134	10	11	2
476	134	10	11	3
477	134	10	11	4
478	135	10	12	1
479	135	10	12	2
480	135	10	12	3
481	135	10	12	4
482	136	65	10	1
483	136	65	10	2
484	136	65	10	3
485	136	65	10	4
486	137	65	9	1
487	137	65	9	2
488	137	65	9	3
489	138	65	8	1
490	138	65	8	2
491	138	65	8	3
492	139	65	8	1
493	139	65	8	2
494	139	65	8	3
495	139	65	8	4
496	140	65	8	1
497	140	65	8	2
498	140	65	8	3
499	141	10	11	1
500	141	10	11	2
501	141	10	11	3
502	142	10	14	1
503	142	10	14	2
504	142	10	14	3
505	143	10	14	1
506	143	10	14	2
507	143	10	14	3
508	144	10	14	1
509	144	10	14	2
510	144	10	14	3
511	145	10	12	1
512	145	10	12	2
513	145	10	12	3
514	146	10	13	1
515	146	10	13	2
516	146	10	13	3
517	147	65	11	1
518	147	65	11	2
519	147	65	11	3
520	147	65	11	4
521	148	65	8	1
522	148	65	8	2
523	148	65	8	3
524	149	65	9	1
525	149	65	9	2
526	149	65	9	3
527	150	65	9	1
528	150	65	9	2
529	150	65	9	3
530	151	65	11	1
531	151	65	11	2
532	151	65	11	3
533	151	65	11	4
534	152	10	13	1
535	152	10	13	2
536	152	10	13	3
537	153	10	12	1
538	153	10	12	2
539	153	10	12	3
540	154	10	14	1
541	154	10	14	2
542	154	10	14	3
543	155	10	10	1
544	155	10	10	2
545	155	10	10	3
546	156	10	14	1
547	156	10	14	2
548	156	10	14	3
549	156	10	14	4
550	157	10	11	1
551	157	10	11	2
552	157	10	11	3
553	158	65	11	1
554	158	65	11	2
555	158	65	11	3
556	158	65	11	4
557	159	65	9	1
558	159	65	9	2
559	159	65	9	3
560	160	65	12	1
561	160	65	12	2
562	160	65	12	3
563	160	65	12	4
564	161	65	12	1
565	161	65	12	2
566	161	65	12	3
567	161	65	12	4
568	162	65	8	1
569	162	65	8	2
570	162	65	8	3
\.


--
-- TOC entry 5105 (class 0 OID 16446)
-- Dependencies: 229
-- Data for Name: workouts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.workouts (id, user_id, date) FROM stdin;
1	1	2025-12-01 08:00:00
2	2	2025-12-01 09:00:00
3	3	2025-12-01 10:00:00
4	1	2025-12-03 08:00:00
5	2	2025-12-03 09:00:00
6	3	2025-12-03 10:00:00
7	1	2025-12-05 08:00:00
8	2	2025-12-05 09:00:00
9	3	2025-12-05 10:00:00
10	1	2025-12-08 08:00:00
11	2	2025-12-08 09:00:00
12	3	2025-12-08 10:00:00
13	1	2025-12-10 08:00:00
14	2	2025-12-10 09:00:00
15	3	2025-12-10 10:00:00
16	1	2025-12-12 08:00:00
17	2	2025-12-12 09:00:00
18	3	2025-12-12 10:00:00
19	1	2025-12-15 08:00:00
20	2	2025-12-15 09:00:00
21	3	2025-12-15 10:00:00
22	1	2025-12-17 08:00:00
23	2	2025-12-17 09:00:00
24	3	2025-12-17 10:00:00
25	4	2025-12-01 16:00:00
26	5	2025-12-01 17:00:00
27	4	2025-12-03 16:00:00
28	5	2025-12-03 17:00:00
29	4	2025-12-05 16:00:00
30	5	2025-12-05 17:00:00
31	4	2025-12-08 16:00:00
32	5	2025-12-08 17:00:00
33	4	2025-12-10 16:00:00
34	5	2025-12-10 17:00:00
35	4	2025-12-12 16:00:00
36	5	2025-12-12 17:00:00
\.


--
-- TOC entry 5123 (class 0 OID 0)
-- Dependencies: 226
-- Name: body_measurements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.body_measurements_id_seq', 5, true);


--
-- TOC entry 5124 (class 0 OID 0)
-- Dependencies: 224
-- Name: exercises_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.exercises_id_seq', 103, true);


--
-- TOC entry 5125 (class 0 OID 0)
-- Dependencies: 222
-- Name: muscle_groups_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.muscle_groups_id_seq', 9, true);


--
-- TOC entry 5126 (class 0 OID 0)
-- Dependencies: 220
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 7, true);


--
-- TOC entry 5127 (class 0 OID 0)
-- Dependencies: 230
-- Name: workout_exercises_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workout_exercises_id_seq', 162, true);


--
-- TOC entry 5128 (class 0 OID 0)
-- Dependencies: 232
-- Name: workout_sets_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workout_sets_id_seq', 570, true);


--
-- TOC entry 5129 (class 0 OID 0)
-- Dependencies: 228
-- Name: workouts_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.workouts_id_seq', 36, true);


--
-- TOC entry 4936 (class 2606 OID 16439)
-- Name: body_measurements body_measurements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.body_measurements
    ADD CONSTRAINT body_measurements_pkey PRIMARY KEY (id);


--
-- TOC entry 4934 (class 2606 OID 16424)
-- Name: exercises exercises_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exercises
    ADD CONSTRAINT exercises_pkey PRIMARY KEY (id);


--
-- TOC entry 4932 (class 2606 OID 16412)
-- Name: muscle_groups muscle_groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.muscle_groups
    ADD CONSTRAINT muscle_groups_pkey PRIMARY KEY (id);


--
-- TOC entry 4930 (class 2606 OID 16403)
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- TOC entry 4940 (class 2606 OID 16469)
-- Name: workout_exercises workout_exercises_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout_exercises
    ADD CONSTRAINT workout_exercises_pkey PRIMARY KEY (id);


--
-- TOC entry 4942 (class 2606 OID 16490)
-- Name: workout_sets workout_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout_sets
    ADD CONSTRAINT workout_sets_pkey PRIMARY KEY (id);


--
-- TOC entry 4938 (class 2606 OID 16454)
-- Name: workouts workouts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workouts
    ADD CONSTRAINT workouts_pkey PRIMARY KEY (id);


--
-- TOC entry 4944 (class 2606 OID 16440)
-- Name: body_measurements body_measurements_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.body_measurements
    ADD CONSTRAINT body_measurements_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- TOC entry 4943 (class 2606 OID 16425)
-- Name: exercises exercises_muscle_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exercises
    ADD CONSTRAINT exercises_muscle_group_id_fkey FOREIGN KEY (muscle_group_id) REFERENCES public.muscle_groups(id);


--
-- TOC entry 4946 (class 2606 OID 16475)
-- Name: workout_exercises workout_exercises_exercise_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout_exercises
    ADD CONSTRAINT workout_exercises_exercise_id_fkey FOREIGN KEY (exercise_id) REFERENCES public.exercises(id);


--
-- TOC entry 4947 (class 2606 OID 16470)
-- Name: workout_exercises workout_exercises_workout_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout_exercises
    ADD CONSTRAINT workout_exercises_workout_id_fkey FOREIGN KEY (workout_id) REFERENCES public.workouts(id);


--
-- TOC entry 4948 (class 2606 OID 16491)
-- Name: workout_sets workout_sets_workout_exercise_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workout_sets
    ADD CONSTRAINT workout_sets_workout_exercise_id_fkey FOREIGN KEY (workout_exercise_id) REFERENCES public.workout_exercises(id);


--
-- TOC entry 4945 (class 2606 OID 16455)
-- Name: workouts workouts_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.workouts
    ADD CONSTRAINT workouts_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);


-- Completed on 2025-12-16 19:17:58

--
-- PostgreSQL database dump complete
--

\unrestrict Qy4bmO4P9g5azUjHxNLyTuvTPyLe3zDWOcZ4zPhaxAyTkgd17FWgCU4rhN02lk3

