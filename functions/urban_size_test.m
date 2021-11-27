urban = [ 0, 0, 0, 0, 0, 0, 0;
          0, 1, 0, 1, 1, 1, 0;
          0, 0, 0, 0, 1, 0, 0;
          0, 1, 1, 0, 1, 0, 0;
          0, 0, 0, 0, 0, 0, 0];

sizes_actual = urban_size(urban, 3);
sizes_expect = [1, 2, 5];