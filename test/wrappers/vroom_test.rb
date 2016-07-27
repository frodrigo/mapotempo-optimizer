# Copyright © Mapotempo, 2016
#
# This file is part of Mapotempo.
#
# Mapotempo is free software. You can redistribute it and/or
# modify since you respect the terms of the GNU Affero General
# Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Mapotempo is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
# or FITNESS FOR A PARTICULAR PURPOSE.  See the Licenses for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with Mapotempo. If not, see:
# <http://www.gnu.org/licenses/agpl.html>
#
require './test/test_helper'


class Wrappers::VroomTest < Minitest::Test

  def test_minimal_problem
    vroom = OptimizerWrapper::VROOM
    problem = {
      matrices: {
        time: [
          [0, 1],
          [1, 0]
        ]
      },
      points: [{
        id: 'point_0',
        matrix_index: 0
      }, {
        id: 'point_1',
        matrix_index: 1
      }],
      services: [{
        id: 'service_0',
        activity: {
          point_id: 'point_0'
        }
      }, {
        id: 'service_1',
        activity: {
          point_id: 'point_1'
        }
      }],
      vehicles: [{
        id: 'vehicle_0',
        start_point_id: 'point_0'
      }]
    }
    vrp = Models::Vrp.create(problem)
    assert vroom.inapplicable_solve?(vrp).empty?
    progress = 0
    result = vroom.solve(vrp) { |avancement, total|
      progress += 1
    }
    assert result
    assert progress > 0
    assert_equal 1, result[:routes].size
    assert_equal problem[:services].size + 2, result[:routes][0][:activities].size # always return activities for start/end
  end

  def test_loop_problem
    vroom = OptimizerWrapper::VROOM
    problem = {
      matrices: {
        time: [
          [0, 655, 1948, 5231, 2971],
          [603, 0, 1692, 4977, 2715],
          [1861, 1636, 0, 6143, 1532],
          [5184, 4951, 6221, 0, 7244],
          [2982, 2758, 1652, 7264, 0],
        ]
      },
      points: [{
        id: 'point_0',
        matrix_index: 0
      }, {
        id: 'point_1',
        matrix_index: 1
      }, {
        id: 'point_2',
        matrix_index: 2
      }, {
        id: 'point_3',
        matrix_index: 3
      }, {
        id: 'point_4',
        matrix_index: 4
      }],
      services: [{
        id: 'service_1',
        activity: {
          point_id: 'point_1'
        }
      }, {
        id: 'service_2',
        activity: {
          point_id: 'point_2'
        }
      }, {
        id: 'service_3',
        activity: {
          point_id: 'point_3'
        }
      }, {
        id: 'service_4',
        activity: {
          point_id: 'point_4'
        }
      }],
      vehicles: [{
        id: 'vehicle_0',
        start_point_id: 'point_0',
        end_point_id: 'point_0',
      }]
    }
    vrp = Models::Vrp.create(problem)
    assert vroom.inapplicable_solve?(vrp).empty?
    result = vroom.solve(vrp)
    assert result
    assert_equal 1, result[:routes].size
    assert_equal problem[:services].size + 2, result[:routes][0][:activities].size # always return activities for start/end
    assert_equal problem[:vehicles][0][:start_point_id], result[:routes][0][:activities][0][:point_id]
    assert_equal problem[:vehicles][0][:end_point_id], result[:routes][0][:activities][-1][:point_id]
    assert_equal problem[:services].collect{ |s| s[:activity][:point_id] }.sort, result[:routes][0][:activities][1..-2].collect{ |a| a[:point_id] }.sort
  end

  def test_no_end_problem
    vroom = OptimizerWrapper::VROOM
    problem = {
      matrices: {
        time: [
          [0, 655, 1948, 5231, 2971],
          [603, 0, 1692, 4977, 2715],
          [1861, 1636, 0, 6143, 1532],
          [5184, 4951, 6221, 0, 7244],
          [2982, 2758, 1652, 7264, 0],
        ]
      },
      points: [{
        id: 'point_0',
        matrix_index: 0
      }, {
        id: 'point_1',
        matrix_index: 1
      }, {
        id: 'point_2',
        matrix_index: 2
      }, {
        id: 'point_3',
        matrix_index: 3
      }, {
        id: 'point_4',
        matrix_index: 4
      }],
      services: [{
        id: 'service_1',
        activity: {
          point_id: 'point_1'
        }
      }, {
        id: 'service_2',
        activity: {
          point_id: 'point_2'
        }
      }, {
        id: 'service_3',
        activity: {
          point_id: 'point_3'
        }
      }, {
        id: 'service_4',
        activity: {
          point_id: 'point_4'
        }
      }],
      vehicles: [{
        id: 'vehicle_0',
        start_point_id: 'point_0',
      }]
    }
    vrp = Models::Vrp.create(problem)
    assert vroom.inapplicable_solve?(vrp).empty?
    result = vroom.solve(vrp)
    assert result
    assert_equal 1, result[:routes].size
    assert_equal problem[:services].size + 2, result[:routes][0][:activities].size # always return activities for start/end
    assert_equal problem[:vehicles][0][:start_point_id], result[:routes][0][:activities][0][:point_id]
    assert_equal result[:routes][0][:activities][-2][:point_id], result[:routes][0][:activities][-1][:point_id]
    assert_equal problem[:services].collect{ |s| s[:activity][:point_id] }.sort, result[:routes][0][:activities][1..-2].collect{ |a| a[:point_id] }.sort
  end
end