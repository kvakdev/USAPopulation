//
//  YearlyPopulationSampleJSON.swift
//  USAPopulationTests
//
//  Created by Andrii Kvashuk on 15/03/2024.
//

import Foundation

extension String  {
    static let yearlyPopulationJSON = """
{
  "data": [
    {
      "ID Year": 2021,
      "Year": "2021",
      "Population": 2560865057
    },
    {
      "ID Year": 2020,
      "Year": "2020",
      "Population": 2535804067
    },
    {
      "ID Year": 2019,
      "Year": "2019",
      "Population": 2519034882
    },
    {
      "ID Year": 2018,
      "Year": "2018",
      "Population": 2505396929
    },
    {
      "ID Year": 2017,
      "Year": "2017",
      "Population": 2491038880
    },
    {
      "ID Year": 2016,
      "Year": "2016",
      "Population": 2472199061
    },
    {
      "ID Year": 2015,
      "Year": "2015",
      "Population": 2455957939
    },
    {
      "ID Year": 2014,
      "Year": "2014",
      "Population": 2437314358
    },
    {
      "ID Year": 2013,
      "Year": "2013",
      "Population": 2417351989
    }
  ],
  "source": [
    {
      "measures": [
        "Population"
      ],
      "annotations": {
        "source_name": "Census Bureau",
        "source_description": "The American Community Survey (ACS) is conducted by the US Census and sent to a portion of the population every year.",
        "dataset_name": "ACS 5-year Estimate",
        "dataset_link": "http://www.census.gov/programs-surveys/acs/",
        "table_id": "B01003",
        "topic": "Diversity",
        "subtopic": "Demographics"
      },
      "name": "acs_yg_total_population_5",
      "substitutions": []
    }
  ]
}
"""
}
