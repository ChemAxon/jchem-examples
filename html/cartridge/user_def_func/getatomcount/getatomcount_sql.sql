
CREATE FUNCTION getatomcount_func(query VARCHAR2) RETURN NUMBER AS
  BEGIN
    return to_number(jchem_core_pkg.send_user_func('GetAtomCount', '', query));
  END;
/
show errors;

CREATE OPERATOR getatomcount BINDING(VARCHAR2) RETURN NUMBER
  USING getatomcount_func;

