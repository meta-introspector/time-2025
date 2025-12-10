% octave_scripts/eigen_script.m
function eigen_script(input_file_path, output_file_path)
    % Load the matrix from the input file
    A = load(input_file_path);

    % Perform eigenvalue decomposition
    [V, D] = eig(A); % V contains eigenvectors, D is a diagonal matrix of eigenvalues

    % Extract eigenvalues
    eigenvalues = diag(D);

    % Open output file for writing
    fid = fopen(output_file_path, 'wt');

    % Write eigenvalues
    fprintf(fid, 'EIGENVALUES:\n');
    for i = 1:length(eigenvalues)
        fprintf(fid, '%f %f\n', real(eigenvalues(i)), imag(eigenvalues(i)));
    end

    % Write eigenvectors
    fprintf(fid, 'EIGENVECTORS:\n');
    % Octave's eig returns V where columns are eigenvectors.
    % To write row by row, we iterate through rows of V.
    for i = 1:rows(V)
        for j = 1:columns(V)
            fprintf(fid, '%f %f ', real(V(i, j)), imag(V(i, j)));
        end
        fprintf(fid, '\n');
    end

    % Close the output file
    fclose(fid);
end
