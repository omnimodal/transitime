/*
 * This file is part of Transitime.org
 * 
 * Transitime.org is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License (GPL) as published by
 * the Free Software Foundation, either version 3 of the License, or
 * any later version.
 *
 * Transitime.org is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Transitime.org .  If not, see <http://www.gnu.org/licenses/>.
 */
package org.transitclock.reports;

import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.transitclock.db.GenericQuery;

public class GenericJsonQuery extends GenericQuery {

	private static final Logger logger = LoggerFactory
			.getLogger(GenericJsonQuery.class);
	private JSONArray data = new JSONArray();
	private List<String> columnNames = new ArrayList<String>();
	
	/**
	 * @param agencyId
	 * @throws SQLException
	 */
	private GenericJsonQuery(String agencyId) throws SQLException {
		super(agencyId);
	}

	/* (non-Javadoc)
	 * @see org.transitclock.db.GenericQuery#addColumn(java.lang.String, int)
	 */
	@Override
	protected void addColumn(String columnName, int type) {
		// Keep track of names of all columns
		columnNames.add(columnName);
	}

	/* (non-Javadoc)
	 * @see org.transitclock.db.GenericQuery#addRow(java.util.List)
	 */
	@Override
	protected void addRow(List<Object> values) {
		JSONObject json = new JSONObject();
		for (int i=0; i<values.size(); ++i) {
			Object o = values.get(i);
			json.put(columnNames.get(i), o);
		}
		data.put(json);
	}
	/**
	 * Does SQL query and returns JSON formatted results.
	 * 
	 * @param agencyId
	 * @param sql
	 * @return
	 * @throws SQLException 
	 */
	public static String getJsonString(String agencyId, String sql, Object...parameters) {
		try {
			GenericJsonQuery query = new GenericJsonQuery(agencyId);
			
			query.doQuery(sql, parameters);

			return new JSONObject().put("data", query.data).toString();
		} catch (SQLException e) {
			return e.getMessage();
		}
	}
	/**
	 * Does SQL query and returns JSON formatted results.
	 * 
	 * @param agencyId
	 * @param sql
	 * @return
	 * @throws SQLException 
	 */
	public static String getJsonString(String agencyId, String sql) {
		try {
			GenericJsonQuery query = new GenericJsonQuery(agencyId);
			
			logger.debug("sql=" + sql);

			query.doQuery(sql);

			return new JSONObject().put("data", query.data).toString();
		} catch (SQLException e) {
			return e.getMessage();
		}
	}

	public static void main(String[] args) {
		String agencyId = "sfmta";
		
		String sql = "SELECT * FROM avlreports ORDER BY time DESC LIMIT 5";
		String str = GenericJsonQuery.getJsonString(agencyId, sql);
		System.out.println(str);
	}
}
