CREATE OR REPLACE FUNCTION get_next_sequence_doc_id(key text) RETURNS bigint AS $$
DECLARE
    sequence_record record;
    next_seq bigint;
BEGIN
    SELECT * INTO sequence_record FROM doc_id_range WHERE id = key;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Doc id not found for key %', key;
    END IF;

    next_seq := sequence_record.sequence + 1;

    UPDATE doc_id_range SET
        sequence = next_seq,
        seq_end = GREATEST(seq_end, next_seq)
    WHERE id = key;

    RETURN next_seq;
EXCEPTION
    WHEN OTHERS THEN
        RAISE EXCEPTION 'Error in get_next_sequence_doc_id: %', SQLERRM;
END;
$$ LANGUAGE plpgsql;
