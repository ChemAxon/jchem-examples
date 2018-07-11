
CREATE FUNCTION molconverter_func(query VARCHAR2, type VARCHAR2) RETURN VARCHAR2 AS
  BEGIN
    return jchem_core_pkg.send_user_func('MolConvert', '{delim}', 
						query || '{delim}' || type);
  END;
/
show errors;

CREATE OPERATOR molconverter BINDING(VARCHAR2, VARCHAR2) RETURN VARCHAR2
  USING molconverter_func;

